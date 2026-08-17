import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const BASE_URL = 'https://speaknow.co.in';
const OUTPUT_DIR = path.join(path.dirname(fileURLToPath(import.meta.url)), 'scraped_data');
const PAGES_DIR = path.join(OUTPUT_DIR, 'pages');
const JSON_DIR = path.join(OUTPUT_DIR, 'json_data');

// Utility to sleep between requests to avoid spamming the server
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Helper to strip HTML tags and decode basic HTML entities
function cleanText(html) {
  if (!html) return '';
  return html
    .replace(/<[^>]+>/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#x27;/g, "'")
    .replace(/&nbsp;/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

async function initDirs() {
  await fs.mkdir(OUTPUT_DIR, { recursive: true });
  await fs.mkdir(PAGES_DIR, { recursive: true });
  await fs.mkdir(JSON_DIR, { recursive: true });
}

// Fetch helper with timeout and basic error handling
async function fetchWithRetry(url, retries = 3, delay = 1000) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
      });
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return await response.text();
    } catch (e) {
      if (i === retries - 1) throw e;
      console.warn(`Fetch failed for ${url}, retrying (${i + 1}/${retries})...`);
      await sleep(delay);
    }
  }
}

// Scrapes sitemap to find all URLs
async function getSitemapUrls() {
  console.log(`Fetching sitemap from ${BASE_URL}/sitemap.xml...`);
  const sitemapXml = await fetchWithRetry(`${BASE_URL}/sitemap.xml`);
  const urls = [];
  const regex = /<loc>(https?:\/\/[^<]+)<\/loc>/g;
  let match;
  while ((match = regex.exec(sitemapXml)) !== null) {
    urls.push(match[1]);
  }
  return urls;
}

// Main logic to crawl each page
async function scrapePage(url) {
  const pagePath = new URL(url).pathname;
  const fileName = pagePath === '/' ? 'home' : pagePath.replace(/^\/|\/$/g, '').replace(/\//g, '-');
  console.log(`Scraping page: ${pagePath} (${url})...`);

  const html = await fetchWithRetry(url);

  // 1. Extract metadata
  const titleMatch = html.match(/<title>([^<]+)<\/title>/i);
  const title = titleMatch ? cleanText(titleMatch[1]) : '';

  const descMatch = html.match(/<meta\s+name="description"\s+content="([^"]*)"/i) || 
                    html.match(/<meta\s+content="([^"]*)"\s+name="description"/i);
  const description = descMatch ? cleanText(descMatch[1]) : '';

  // 2. Extract JSON-LD scripts (LD+JSON has structured FAQs, Breadcrumbs, etc.)
  const ldJsonScripts = [];
  const ldRegex = /<script\s+type="application\/ld\+json">([\s\S]*?)<\/script>/gi;
  let ldMatch;
  while ((ldMatch = ldRegex.exec(html)) !== null) {
    try {
      const parsed = JSON.parse(ldMatch[1].trim());
      ldJsonScripts.push(parsed);
    } catch (e) {
      // Ignore invalid JSON-LD
    }
  }

  // 3. Extract text content (H1, H2, H3, paragraphs)
  const headings = [];
  const hRegex = /<(h[1-3])[^>]*>([\s\S]*?)<\/h[1-3]>/gi;
  let hMatch;
  while ((hMatch = hRegex.exec(html)) !== null) {
    headings.push({
      tag: hMatch[1].toLowerCase(),
      text: cleanText(hMatch[2])
    });
  }

  const paragraphs = [];
  const pRegex = /<p[^>]*>([\s\S]*?)<\/p>/gi;
  let pMatch;
  while ((pMatch = pRegex.exec(html)) !== null) {
    const text = cleanText(pMatch[1]);
    if (text && !text.includes('🔒') && !text.includes('If SpeakNow is helping you')) {
      paragraphs.push(text);
    }
  }

  // 4. Extract Next.js JS chunks
  const jsChunks = [];
  const scriptRegex = /<script[^>]*src="(\/_next\/static\/chunks\/[^"]+\.js)"/gi;
  let scriptMatch;
  while ((scriptMatch = scriptRegex.exec(html)) !== null) {
    jsChunks.push(`${BASE_URL}${scriptMatch[1]}`);
  }

  // 5. Build structured page payload
  const pageData = {
    url,
    path: pagePath,
    title,
    description,
    headings,
    paragraphs,
    ldJson: ldJsonScripts
  };

  await fs.writeFile(
    path.join(PAGES_DIR, `${fileName}.json`),
    JSON.stringify(pageData, null, 2)
  );

  return { jsChunks, pagePath, title };
}

// Analyzes JS chunks for any references to static JSON files
async function discoverJsonFiles(jsUrls) {
  const jsonUrls = new Set();
  const jsonRegex = /"(\/[^"]+\.json)"|'(\/[^']+\.json)'/g;

  for (const jsUrl of jsUrls) {
    try {
      console.log(`Analyzing JS chunk: ${jsUrl.substring(jsUrl.lastIndexOf('/'))}`);
      const code = await fetchWithRetry(jsUrl);
      let match;
      while ((match = jsonRegex.exec(code)) !== null) {
        const jsonPath = match[1] || match[2];
        // Filter out manifest or standard non-data json files
        if (jsonPath && !jsonPath.includes('manifest.json') && !jsonPath.includes('browserconfig.json')) {
          jsonUrls.add(`${BASE_URL}${jsonPath}`);
        }
      }
    } catch (e) {
      console.warn(`Failed to retrieve or parse JS chunk: ${jsUrl}`);
    }
  }

  return Array.from(jsonUrls);
}

// Main execution function
async function main() {
  console.log('--- SpeakNow Data Scraper ---');
  await initDirs();

  const urls = await getSitemapUrls();
  console.log(`Discovered ${urls.length} URLs in sitemap.`);

  const allJsChunks = new Set();
  const scrapedPages = [];

  for (const url of urls) {
    try {
      const { jsChunks, pagePath, title } = await scrapePage(url);
      jsChunks.forEach(chunk => allJsChunks.add(chunk));
      scrapedPages.push({ path: pagePath, title, url });
      // Adaptive delay to respect the server limits
      await sleep(500);
    } catch (e) {
      console.error(`Error scraping page ${url}:`, e);
    }
  }

  console.log('\nScanning Javascript chunks for static JSON data files...');
  const jsonUrls = await discoverJsonFiles(Array.from(allJsChunks));
  console.log(`Discovered ${jsonUrls.length} static JSON files to download.`);

  const downloadedJsonFiles = [];
  for (const jsonUrl of jsonUrls) {
    try {
      const fileName = jsonUrl.substring(jsonUrl.lastIndexOf('/') + 1);
      console.log(`Downloading static JSON: ${fileName}...`);
      const dataStr = await fetchWithRetry(jsonUrl);
      // Validate that it's parsed as JSON
      const parsed = JSON.parse(dataStr);
      await fs.writeFile(
        path.join(JSON_DIR, fileName),
        JSON.stringify(parsed, null, 2)
      );
      downloadedJsonFiles.push(fileName);
      await sleep(200);
    } catch (e) {
      console.error(`Failed to download static JSON ${jsonUrl}:`, e.message);
    }
  }

  // Create a master summary JSON file
  const summary = {
    totalUrls: urls.length,
    scrapedPagesCount: scrapedPages.length,
    downloadedJsonFilesCount: downloadedJsonFiles.length,
    scrapedPages,
    downloadedJsonFiles,
    timestamp: new Date().toISOString()
  };

  await fs.writeFile(
    path.join(OUTPUT_DIR, 'summary.json'),
    JSON.stringify(summary, null, 2)
  );

  console.log('\n--- Scraping Completed Successfully! ---');
  console.log(`Metadata and page text stored in: ${PAGES_DIR}`);
  console.log(`Static JSON datasets stored in: ${JSON_DIR}`);
  console.log(`Summary report written to: ${path.join(OUTPUT_DIR, 'summary.json')}`);
}

main().catch(err => {
  console.error('Fatal error during scraping execution:', err);
});
