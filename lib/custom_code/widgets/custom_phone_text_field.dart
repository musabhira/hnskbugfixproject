// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/services.dart';

class CustomPhoneTextField extends StatefulWidget {
  final double width;
  final double height;
  final String labelText;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? initialCountryCode;
  final TextEditingController controller;

  const CustomPhoneTextField({
    required this.width,
    required this.height,
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.phone,
    this.initialCountryCode,
  });

  @override
  State<CustomPhoneTextField> createState() => _CustomPhoneTextFieldState();
}

class _CustomPhoneTextFieldState extends State<CustomPhoneTextField> {
  late CountryCode _selectedCountry;
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isCountryListOpen = false;
  final FocusNode _focusNode = FocusNode();

  // Create a controller for search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Map of country codes organized by regions
  final Map<String, List<CountryCode>> _countriesByRegion = {
    'Popular': [
      CountryCode(
        name: 'United States',
        code: 'US',
        dialCode: '+1',
        flag: '🇺🇸',
      ),
      CountryCode(
        name: 'India',
        code: 'IN',
        dialCode: '+91',
        flag: '🇮🇳',
      ),
      CountryCode(
        name: 'United Kingdom',
        code: 'GB',
        dialCode: '+44',
        flag: '🇬🇧',
      ),
      CountryCode(
        name: 'Canada',
        code: 'CA',
        dialCode: '+1',
        flag: '🇨🇦',
      ),
      CountryCode(
        name: 'Australia',
        code: 'AU',
        dialCode: '+61',
        flag: '🇦🇺',
      ),
    ],
    'All Countries': [
      CountryCode(
        name: 'Afghanistan',
        code: 'AF',
        dialCode: '+93',
        flag: '🇦🇫',
      ),
      CountryCode(
        name: 'Albania',
        code: 'AL',
        dialCode: '+355',
        flag: '🇦🇱',
      ),
      CountryCode(
        name: 'Algeria',
        code: 'DZ',
        dialCode: '+213',
        flag: '🇩🇿',
      ),
      CountryCode(
        name: 'Andorra',
        code: 'AD',
        dialCode: '+376',
        flag: '🇦🇩',
      ),
      CountryCode(
        name: 'Angola',
        code: 'AO',
        dialCode: '+244',
        flag: '🇦🇴',
      ),
      CountryCode(
        name: 'Argentina',
        code: 'AR',
        dialCode: '+54',
        flag: '🇦🇷',
      ),
      CountryCode(
        name: 'Armenia',
        code: 'AM',
        dialCode: '+374',
        flag: '🇦🇲',
      ),
      CountryCode(
        name: 'Australia',
        code: 'AU',
        dialCode: '+61',
        flag: '🇦🇺',
      ),
      CountryCode(
        name: 'Austria',
        code: 'AT',
        dialCode: '+43',
        flag: '🇦🇹',
      ),
      CountryCode(
        name: 'Azerbaijan',
        code: 'AZ',
        dialCode: '+994',
        flag: '🇦🇿',
      ),
      CountryCode(
        name: 'Bahamas',
        code: 'BS',
        dialCode: '+1',
        flag: '🇧🇸',
      ),
      CountryCode(
        name: 'Bahrain',
        code: 'BH',
        dialCode: '+973',
        flag: '🇧🇭',
      ),
      CountryCode(
        name: 'Bangladesh',
        code: 'BD',
        dialCode: '+880',
        flag: '🇧🇩',
      ),
      CountryCode(
        name: 'Barbados',
        code: 'BB',
        dialCode: '+1',
        flag: '🇧🇧',
      ),
      CountryCode(
        name: 'Belarus',
        code: 'BY',
        dialCode: '+375',
        flag: '🇧🇾',
      ),
      CountryCode(
        name: 'Belgium',
        code: 'BE',
        dialCode: '+32',
        flag: '🇧🇪',
      ),
      CountryCode(
        name: 'Belize',
        code: 'BZ',
        dialCode: '+501',
        flag: '🇧🇿',
      ),
      CountryCode(
        name: 'Benin',
        code: 'BJ',
        dialCode: '+229',
        flag: '🇧🇯',
      ),
      CountryCode(
        name: 'Bhutan',
        code: 'BT',
        dialCode: '+975',
        flag: '🇧🇹',
      ),
      CountryCode(
        name: 'Bolivia',
        code: 'BO',
        dialCode: '+591',
        flag: '🇧🇴',
      ),
      CountryCode(
        name: 'Bosnia and Herzegovina',
        code: 'BA',
        dialCode: '+387',
        flag: '🇧🇦',
      ),
      CountryCode(
        name: 'Botswana',
        code: 'BW',
        dialCode: '+267',
        flag: '🇧🇼',
      ),
      CountryCode(
        name: 'Brazil',
        code: 'BR',
        dialCode: '+55',
        flag: '🇧🇷',
      ),
      CountryCode(
        name: 'Brunei',
        code: 'BN',
        dialCode: '+673',
        flag: '🇧🇳',
      ),
      CountryCode(
        name: 'Bulgaria',
        code: 'BG',
        dialCode: '+359',
        flag: '🇧🇬',
      ),
      CountryCode(
        name: 'Burkina Faso',
        code: 'BF',
        dialCode: '+226',
        flag: '🇧🇫',
      ),
      CountryCode(
        name: 'Burundi',
        code: 'BI',
        dialCode: '+257',
        flag: '🇧🇮',
      ),
      CountryCode(
        name: 'Cambodia',
        code: 'KH',
        dialCode: '+855',
        flag: '🇰🇭',
      ),
      CountryCode(
        name: 'Cameroon',
        code: 'CM',
        dialCode: '+237',
        flag: '🇨🇲',
      ),
      CountryCode(
        name: 'Canada',
        code: 'CA',
        dialCode: '+1',
        flag: '🇨🇦',
      ),
      CountryCode(
        name: 'Cape Verde',
        code: 'CV',
        dialCode: '+238',
        flag: '🇨🇻',
      ),
      CountryCode(
        name: 'Central African Republic',
        code: 'CF',
        dialCode: '+236',
        flag: '🇨🇫',
      ),
      CountryCode(
        name: 'Chad',
        code: 'TD',
        dialCode: '+235',
        flag: '🇹🇩',
      ),
      CountryCode(
        name: 'Chile',
        code: 'CL',
        dialCode: '+56',
        flag: '🇨🇱',
      ),
      CountryCode(
        name: 'China',
        code: 'CN',
        dialCode: '+86',
        flag: '🇨🇳',
      ),
      CountryCode(
        name: 'Colombia',
        code: 'CO',
        dialCode: '+57',
        flag: '🇨🇴',
      ),
      CountryCode(
        name: 'Comoros',
        code: 'KM',
        dialCode: '+269',
        flag: '🇰🇲',
      ),
      CountryCode(
        name: 'Congo',
        code: 'CG',
        dialCode: '+242',
        flag: '🇨🇬',
      ),
      CountryCode(
        name: 'Costa Rica',
        code: 'CR',
        dialCode: '+506',
        flag: '🇨🇷',
      ),
      CountryCode(
        name: 'Croatia',
        code: 'HR',
        dialCode: '+385',
        flag: '🇭🇷',
      ),
      CountryCode(
        name: 'Cuba',
        code: 'CU',
        dialCode: '+53',
        flag: '🇨🇺',
      ),
      CountryCode(
        name: 'Cyprus',
        code: 'CY',
        dialCode: '+357',
        flag: '🇨🇾',
      ),
      CountryCode(
        name: 'Czech Republic',
        code: 'CZ',
        dialCode: '+420',
        flag: '🇨🇿',
      ),
      CountryCode(
        name: 'Democratic Republic of the Congo',
        code: 'CD',
        dialCode: '+243',
        flag: '🇨🇩',
      ),
      CountryCode(
        name: 'Denmark',
        code: 'DK',
        dialCode: '+45',
        flag: '🇩🇰',
      ),
      CountryCode(
        name: 'Djibouti',
        code: 'DJ',
        dialCode: '+253',
        flag: '🇩🇯',
      ),
      CountryCode(
        name: 'Dominica',
        code: 'DM',
        dialCode: '+1',
        flag: '🇩🇲',
      ),
      CountryCode(
        name: 'Dominican Republic',
        code: 'DO',
        dialCode: '+1',
        flag: '🇩🇴',
      ),
      CountryCode(
        name: 'Ecuador',
        code: 'EC',
        dialCode: '+593',
        flag: '🇪🇨',
      ),
      CountryCode(
        name: 'Egypt',
        code: 'EG',
        dialCode: '+20',
        flag: '🇪🇬',
      ),
      CountryCode(
        name: 'El Salvador',
        code: 'SV',
        dialCode: '+503',
        flag: '🇸🇻',
      ),
      CountryCode(
        name: 'Equatorial Guinea',
        code: 'GQ',
        dialCode: '+240',
        flag: '🇬🇶',
      ),
      CountryCode(
        name: 'Eritrea',
        code: 'ER',
        dialCode: '+291',
        flag: '🇪🇷',
      ),
      CountryCode(
        name: 'Estonia',
        code: 'EE',
        dialCode: '+372',
        flag: '🇪🇪',
      ),
      CountryCode(
        name: 'Ethiopia',
        code: 'ET',
        dialCode: '+251',
        flag: '🇪🇹',
      ),
      CountryCode(
        name: 'Fiji',
        code: 'FJ',
        dialCode: '+679',
        flag: '🇫🇯',
      ),
      CountryCode(
        name: 'Finland',
        code: 'FI',
        dialCode: '+358',
        flag: '🇫🇮',
      ),
      CountryCode(
        name: 'France',
        code: 'FR',
        dialCode: '+33',
        flag: '🇫🇷',
      ),
      CountryCode(
        name: 'Gabon',
        code: 'GA',
        dialCode: '+241',
        flag: '🇬🇦',
      ),
      CountryCode(
        name: 'Gambia',
        code: 'GM',
        dialCode: '+220',
        flag: '🇬🇲',
      ),
      CountryCode(
        name: 'Georgia',
        code: 'GE',
        dialCode: '+995',
        flag: '🇬🇪',
      ),
      CountryCode(
        name: 'Germany',
        code: 'DE',
        dialCode: '+49',
        flag: '🇩🇪',
      ),
      CountryCode(
        name: 'Ghana',
        code: 'GH',
        dialCode: '+233',
        flag: '🇬🇭',
      ),
      CountryCode(
        name: 'Greece',
        code: 'GR',
        dialCode: '+30',
        flag: '🇬🇷',
      ),
      CountryCode(
        name: 'Grenada',
        code: 'GD',
        dialCode: '+1',
        flag: '🇬🇩',
      ),
      CountryCode(
        name: 'Guatemala',
        code: 'GT',
        dialCode: '+502',
        flag: '🇬🇹',
      ),
      CountryCode(
        name: 'Guinea',
        code: 'GN',
        dialCode: '+224',
        flag: '🇬🇳',
      ),
      CountryCode(
        name: 'Guinea-Bissau',
        code: 'GW',
        dialCode: '+245',
        flag: '🇬🇼',
      ),
      CountryCode(
        name: 'Guyana',
        code: 'GY',
        dialCode: '+592',
        flag: '🇬🇾',
      ),
      CountryCode(
        name: 'Haiti',
        code: 'HT',
        dialCode: '+509',
        flag: '🇭🇹',
      ),
      CountryCode(
        name: 'Honduras',
        code: 'HN',
        dialCode: '+504',
        flag: '🇭🇳',
      ),
      CountryCode(
        name: 'Hungary',
        code: 'HU',
        dialCode: '+36',
        flag: '🇭🇺',
      ),
      CountryCode(
        name: 'Iceland',
        code: 'IS',
        dialCode: '+354',
        flag: '🇮🇸',
      ),
      CountryCode(
        name: 'India',
        code: 'IN',
        dialCode: '+91',
        flag: '🇮🇳',
      ),
      CountryCode(
        name: 'Indonesia',
        code: 'ID',
        dialCode: '+62',
        flag: '🇮🇩',
      ),
      CountryCode(
        name: 'Iran',
        code: 'IR',
        dialCode: '+98',
        flag: '🇮🇷',
      ),
      CountryCode(
        name: 'Iraq',
        code: 'IQ',
        dialCode: '+964',
        flag: '🇮🇶',
      ),
      CountryCode(
        name: 'Ireland',
        code: 'IE',
        dialCode: '+353',
        flag: '🇮🇪',
      ),
      CountryCode(
        name: 'Israel',
        code: 'IL',
        dialCode: '+972',
        flag: '🇮🇱',
      ),
      CountryCode(
        name: 'Italy',
        code: 'IT',
        dialCode: '+39',
        flag: '🇮🇹',
      ),
      CountryCode(
        name: 'Ivory Coast',
        code: 'CI',
        dialCode: '+225',
        flag: '🇨🇮',
      ),
      CountryCode(
        name: 'Jamaica',
        code: 'JM',
        dialCode: '+1',
        flag: '🇯🇲',
      ),
      CountryCode(
        name: 'Japan',
        code: 'JP',
        dialCode: '+81',
        flag: '🇯🇵',
      ),
      CountryCode(
        name: 'Jordan',
        code: 'JO',
        dialCode: '+962',
        flag: '🇯🇴',
      ),
      CountryCode(
        name: 'Kazakhstan',
        code: 'KZ',
        dialCode: '+7',
        flag: '🇰🇿',
      ),
      CountryCode(
        name: 'Kenya',
        code: 'KE',
        dialCode: '+254',
        flag: '🇰🇪',
      ),
      CountryCode(
        name: 'Kiribati',
        code: 'KI',
        dialCode: '+686',
        flag: '🇰🇮',
      ),
      CountryCode(
        name: 'Kuwait',
        code: 'KW',
        dialCode: '+965',
        flag: '🇰🇼',
      ),
      CountryCode(
        name: 'Kyrgyzstan',
        code: 'KG',
        dialCode: '+996',
        flag: '🇰🇬',
      ),
      CountryCode(
        name: 'Laos',
        code: 'LA',
        dialCode: '+856',
        flag: '🇱🇦',
      ),
      CountryCode(
        name: 'Latvia',
        code: 'LV',
        dialCode: '+371',
        flag: '🇱🇻',
      ),
      CountryCode(
        name: 'Lebanon',
        code: 'LB',
        dialCode: '+961',
        flag: '🇱🇧',
      ),
      CountryCode(
        name: 'Lesotho',
        code: 'LS',
        dialCode: '+266',
        flag: '🇱🇸',
      ),
      CountryCode(
        name: 'Liberia',
        code: 'LR',
        dialCode: '+231',
        flag: '🇱🇷',
      ),
      CountryCode(
        name: 'Libya',
        code: 'LY',
        dialCode: '+218',
        flag: '🇱🇾',
      ),
      CountryCode(
        name: 'Liechtenstein',
        code: 'LI',
        dialCode: '+423',
        flag: '🇱🇮',
      ),
      CountryCode(
        name: 'Lithuania',
        code: 'LT',
        dialCode: '+370',
        flag: '🇱🇹',
      ),
      CountryCode(
        name: 'Luxembourg',
        code: 'LU',
        dialCode: '+352',
        flag: '🇱🇺',
      ),
      CountryCode(
        name: 'Madagascar',
        code: 'MG',
        dialCode: '+261',
        flag: '🇲🇬',
      ),
      CountryCode(
        name: 'Malawi',
        code: 'MW',
        dialCode: '+265',
        flag: '🇲🇼',
      ),
      CountryCode(
        name: 'Malaysia',
        code: 'MY',
        dialCode: '+60',
        flag: '🇲🇾',
      ),
      CountryCode(
        name: 'Maldives',
        code: 'MV',
        dialCode: '+960',
        flag: '🇲🇻',
      ),
      CountryCode(
        name: 'Mali',
        code: 'ML',
        dialCode: '+223',
        flag: '🇲🇱',
      ),
      CountryCode(
        name: 'Malta',
        code: 'MT',
        dialCode: '+356',
        flag: '🇲🇹',
      ),
      CountryCode(
        name: 'Marshall Islands',
        code: 'MH',
        dialCode: '+692',
        flag: '🇲🇭',
      ),
      CountryCode(
        name: 'Mauritania',
        code: 'MR',
        dialCode: '+222',
        flag: '🇲🇷',
      ),
      CountryCode(
        name: 'Mauritius',
        code: 'MU',
        dialCode: '+230',
        flag: '🇲🇺',
      ),
      CountryCode(
        name: 'Mexico',
        code: 'MX',
        dialCode: '+52',
        flag: '🇲🇽',
      ),
      CountryCode(
        name: 'Micronesia',
        code: 'FM',
        dialCode: '+691',
        flag: '🇫🇲',
      ),
      CountryCode(
        name: 'Moldova',
        code: 'MD',
        dialCode: '+373',
        flag: '🇲🇩',
      ),
      CountryCode(
        name: 'Monaco',
        code: 'MC',
        dialCode: '+377',
        flag: '🇲🇨',
      ),
      CountryCode(
        name: 'Mongolia',
        code: 'MN',
        dialCode: '+976',
        flag: '🇲🇳',
      ),
      CountryCode(
        name: 'Montenegro',
        code: 'ME',
        dialCode: '+382',
        flag: '🇲🇪',
      ),
      CountryCode(
        name: 'Morocco',
        code: 'MA',
        dialCode: '+212',
        flag: '🇲🇦',
      ),
      CountryCode(
        name: 'Mozambique',
        code: 'MZ',
        dialCode: '+258',
        flag: '🇲🇿',
      ),
      CountryCode(
        name: 'Myanmar',
        code: 'MM',
        dialCode: '+95',
        flag: '🇲🇲',
      ),
      CountryCode(
        name: 'Namibia',
        code: 'NA',
        dialCode: '+264',
        flag: '🇳🇦',
      ),
      CountryCode(
        name: 'Nauru',
        code: 'NR',
        dialCode: '+674',
        flag: '🇳🇷',
      ),
      CountryCode(
        name: 'Nepal',
        code: 'NP',
        dialCode: '+977',
        flag: '🇳🇵',
      ),
      CountryCode(
        name: 'Netherlands',
        code: 'NL',
        dialCode: '+31',
        flag: '🇳🇱',
      ),
      CountryCode(
        name: 'New Zealand',
        code: 'NZ',
        dialCode: '+64',
        flag: '🇳🇿',
      ),
      CountryCode(
        name: 'Nicaragua',
        code: 'NI',
        dialCode: '+505',
        flag: '🇳🇮',
      ),
      CountryCode(
        name: 'Niger',
        code: 'NE',
        dialCode: '+227',
        flag: '🇳🇪',
      ),
      CountryCode(
        name: 'Nigeria',
        code: 'NG',
        dialCode: '+234',
        flag: '🇳🇬',
      ),
      CountryCode(
        name: 'North Korea',
        code: 'KP',
        dialCode: '+850',
        flag: '🇰🇵',
      ),
      CountryCode(
        name: 'North Macedonia',
        code: 'MK',
        dialCode: '+389',
        flag: '🇲🇰',
      ),
      CountryCode(
        name: 'Norway',
        code: 'NO',
        dialCode: '+47',
        flag: '🇳🇴',
      ),
      CountryCode(
        name: 'Oman',
        code: 'OM',
        dialCode: '+968',
        flag: '🇴🇲',
      ),
      CountryCode(
        name: 'Pakistan',
        code: 'PK',
        dialCode: '+92',
        flag: '🇵🇰',
      ),
      CountryCode(
        name: 'Palau',
        code: 'PW',
        dialCode: '+680',
        flag: '🇵🇼',
      ),
      CountryCode(
        name: 'Palestine',
        code: 'PS',
        dialCode: '+970',
        flag: '🇵🇸',
      ),
      CountryCode(
        name: 'Panama',
        code: 'PA',
        dialCode: '+507',
        flag: '🇵🇦',
      ),
      CountryCode(
        name: 'Papua New Guinea',
        code: 'PG',
        dialCode: '+675',
        flag: '🇵🇬',
      ),
      CountryCode(
        name: 'Paraguay',
        code: 'PY',
        dialCode: '+595',
        flag: '🇵🇾',
      ),
      CountryCode(
        name: 'Peru',
        code: 'PE',
        dialCode: '+51',
        flag: '🇵🇪',
      ),
      CountryCode(
        name: 'Philippines',
        code: 'PH',
        dialCode: '+63',
        flag: '🇵🇭',
      ),
      CountryCode(
        name: 'Poland',
        code: 'PL',
        dialCode: '+48',
        flag: '🇵🇱',
      ),
      CountryCode(
        name: 'Portugal',
        code: 'PT',
        dialCode: '+351',
        flag: '🇵🇹',
      ),
      CountryCode(
        name: 'Qatar',
        code: 'QA',
        dialCode: '+974',
        flag: '🇶🇦',
      ),
      CountryCode(
        name: 'Romania',
        code: 'RO',
        dialCode: '+40',
        flag: '🇷🇴',
      ),
      CountryCode(
        name: 'Russia',
        code: 'RU',
        dialCode: '+7',
        flag: '🇷🇺',
      ),
      CountryCode(
        name: 'Rwanda',
        code: 'RW',
        dialCode: '+250',
        flag: '🇷🇼',
      ),
      CountryCode(
        name: 'Saint Kitts and Nevis',
        code: 'KN',
        dialCode: '+1',
        flag: '🇰🇳',
      ),
      CountryCode(
        name: 'Saint Lucia',
        code: 'LC',
        dialCode: '+1',
        flag: '🇱🇨',
      ),
      CountryCode(
        name: 'Saint Vincent and the Grenadines',
        code: 'VC',
        dialCode: '+1',
        flag: '🇻🇨',
      ),
      CountryCode(
        name: 'Samoa',
        code: 'WS',
        dialCode: '+685',
        flag: '🇼🇸',
      ),
      CountryCode(
        name: 'San Marino',
        code: 'SM',
        dialCode: '+378',
        flag: '🇸🇲',
      ),
      CountryCode(
        name: 'Sao Tome and Principe',
        code: 'ST',
        dialCode: '+239',
        flag: '🇸🇹',
      ),
      CountryCode(
        name: 'Saudi Arabia',
        code: 'SA',
        dialCode: '+966',
        flag: '🇸🇦',
      ),
      CountryCode(
        name: 'Senegal',
        code: 'SN',
        dialCode: '+221',
        flag: '🇸🇳',
      ),
      CountryCode(
        name: 'Serbia',
        code: 'RS',
        dialCode: '+381',
        flag: '🇷🇸',
      ),
      CountryCode(
        name: 'Seychelles',
        code: 'SC',
        dialCode: '+248',
        flag: '🇸🇨',
      ),
      CountryCode(
        name: 'Sierra Leone',
        code: 'SL',
        dialCode: '+232',
        flag: '🇸🇱',
      ),
      CountryCode(
        name: 'Singapore',
        code: 'SG',
        dialCode: '+65',
        flag: '🇸🇬',
      ),
      CountryCode(
        name: 'Slovakia',
        code: 'SK',
        dialCode: '+421',
        flag: '🇸🇰',
      ),
      CountryCode(
        name: 'Slovenia',
        code: 'SI',
        dialCode: '+386',
        flag: '🇸🇮',
      ),
      CountryCode(
        name: 'Solomon Islands',
        code: 'SB',
        dialCode: '+677',
        flag: '🇸🇧',
      ),
      CountryCode(
        name: 'Somalia',
        code: 'SO',
        dialCode: '+252',
        flag: '🇸🇴',
      ),
      CountryCode(
        name: 'South Africa',
        code: 'ZA',
        dialCode: '+27',
        flag: '🇿🇦',
      ),
      CountryCode(
        name: 'South Korea',
        code: 'KR',
        dialCode: '+82',
        flag: '🇰🇷',
      ),
      CountryCode(
        name: 'South Sudan',
        code: 'SS',
        dialCode: '+211',
        flag: '🇸🇸',
      ),
      CountryCode(
        name: 'Spain',
        code: 'ES',
        dialCode: '+34',
        flag: '🇪🇸',
      ),
      CountryCode(
        name: 'Sri Lanka',
        code: 'LK',
        dialCode: '+94',
        flag: '🇱🇰',
      ),
      CountryCode(
        name: 'Sudan',
        code: 'SD',
        dialCode: '+249',
        flag: '🇸🇩',
      ),
      CountryCode(
        name: 'Suriname',
        code: 'SR',
        dialCode: '+597',
        flag: '🇸🇷',
      ),
      CountryCode(
        name: 'Sweden',
        code: 'SE',
        dialCode: '+46',
        flag: '🇸🇪',
      ),
      CountryCode(
        name: 'Switzerland',
        code: 'CH',
        dialCode: '+41',
        flag: '🇨🇭',
      ),
      CountryCode(
        name: 'Syria',
        code: 'SY',
        dialCode: '+963',
        flag: '🇸🇾',
      ),
      CountryCode(
        name: 'Taiwan',
        code: 'TW',
        dialCode: '+886',
        flag: '🇹🇼',
      ),
      CountryCode(
        name: 'Tajikistan',
        code: 'TJ',
        dialCode: '+992',
        flag: '🇹🇯',
      ),
      CountryCode(
        name: 'Tanzania',
        code: 'TZ',
        dialCode: '+255',
        flag: '🇹🇿',
      ),
      CountryCode(
        name: 'Thailand',
        code: 'TH',
        dialCode: '+66',
        flag: '🇹🇭',
      ),
      CountryCode(
        name: 'Timor-Leste',
        code: 'TL',
        dialCode: '+670',
        flag: '🇹🇱',
      ),
      CountryCode(
        name: 'Togo',
        code: 'TG',
        dialCode: '+228',
        flag: '🇹🇬',
      ),
      CountryCode(
        name: 'Tonga',
        code: 'TO',
        dialCode: '+676',
        flag: '🇹🇴',
      ),
      CountryCode(
        name: 'Trinidad and Tobago',
        code: 'TT',
        dialCode: '+1',
        flag: '🇹🇹',
      ),
      CountryCode(
        name: 'Tunisia',
        code: 'TN',
        dialCode: '+216',
        flag: '🇹🇳',
      ),
      CountryCode(
        name: 'Turkey',
        code: 'TR',
        dialCode: '+90',
        flag: '🇹🇷',
      ),
      CountryCode(
        name: 'Turkmenistan',
        code: 'TM',
        dialCode: '+993',
        flag: '🇹🇲',
      ),
      CountryCode(
        name: 'Tuvalu',
        code: 'TV',
        dialCode: '+688',
        flag: '🇹🇻',
      ),
      CountryCode(
        name: 'Uganda',
        code: 'UG',
        dialCode: '+256',
        flag: '🇺🇬',
      ),
      CountryCode(
        name: 'Ukraine',
        code: 'UA',
        dialCode: '+380',
        flag: '🇺🇦',
      ),
      CountryCode(
        name: 'United Arab Emirates',
        code: 'AE',
        dialCode: '+971',
        flag: '🇦🇪',
      ),
      CountryCode(
        name: 'United Kingdom',
        code: 'GB',
        dialCode: '+44',
        flag: '🇬🇧',
      ),
      CountryCode(
        name: 'United States',
        code: 'US',
        dialCode: '+1',
        flag: '🇺🇸',
      ),
      CountryCode(
        name: 'Uruguay',
        code: 'UY',
        dialCode: '+598',
        flag: '🇺🇾',
      ),
      CountryCode(
        name: 'Uzbekistan',
        code: 'UZ',
        dialCode: '+998',
        flag: '🇺🇿',
      ),
      CountryCode(
        name: 'Vanuatu',
        code: 'VU',
        dialCode: '+678',
        flag: '🇻🇺',
      ),
      CountryCode(
        name: 'Vatican City',
        code: 'VA',
        dialCode: '+39',
        flag: '🇻🇦',
      ),
      CountryCode(
        name: 'Venezuela',
        code: 'VE',
        dialCode: '+58',
        flag: '🇻🇪',
      ),
      CountryCode(
        name: 'Vietnam',
        code: 'VN',
        dialCode: '+84',
        flag: '🇻🇳',
      ),
      CountryCode(
        name: 'Yemen',
        code: 'YE',
        dialCode: '+967',
        flag: '🇾🇪',
      ),
      CountryCode(
        name: 'Zambia',
        code: 'ZM',
        dialCode: '+260',
        flag: '🇿🇲',
      ),
      CountryCode(
        name: 'Zimbabwe',
        code: 'ZW',
        dialCode: '+263',
        flag: '🇿🇼',
      ),
    ],
    'North America': [
      CountryCode(
        name: 'United States',
        code: 'US',
        dialCode: '+1',
        flag: '🇺🇸',
      ),
      CountryCode(
        name: 'Canada',
        code: 'CA',
        dialCode: '+1',
        flag: '🇨🇦',
      ),
      CountryCode(
        name: 'Mexico',
        code: 'MX',
        dialCode: '+52',
        flag: '🇲🇽',
      ),
    ],
    'Europe': [
      CountryCode(
        name: 'United Kingdom',
        code: 'GB',
        dialCode: '+44',
        flag: '🇬🇧',
      ),
      CountryCode(
        name: 'Germany',
        code: 'DE',
        dialCode: '+49',
        flag: '🇩🇪',
      ),
      CountryCode(
        name: 'France',
        code: 'FR',
        dialCode: '+33',
        flag: '🇫🇷',
      ),
      CountryCode(
        name: 'Italy',
        code: 'IT',
        dialCode: '+39',
        flag: '🇮🇹',
      ),
      CountryCode(
        name: 'Spain',
        code: 'ES',
        dialCode: '+34',
        flag: '🇪🇸',
      ),
      CountryCode(
        name: 'Netherlands',
        code: 'NL',
        dialCode: '+31',
        flag: '🇳🇱',
      ),
      CountryCode(
        name: 'Belgium',
        code: 'BE',
        dialCode: '+32',
        flag: '🇧🇪',
      ),
      CountryCode(
        name: 'Sweden',
        code: 'SE',
        dialCode: '+46',
        flag: '🇸🇪',
      ),
      CountryCode(
        name: 'Norway',
        code: 'NO',
        dialCode: '+47',
        flag: '🇳🇴',
      ),
      CountryCode(
        name: 'Finland',
        code: 'FI',
        dialCode: '+358',
        flag: '🇫🇮',
      ),
      CountryCode(
        name: 'Denmark',
        code: 'DK',
        dialCode: '+45',
        flag: '🇩🇰',
      ),
      CountryCode(
        name: 'Poland',
        code: 'PL',
        dialCode: '+48',
        flag: '🇵🇱',
      ),
      CountryCode(
        name: 'Austria',
        code: 'AT',
        dialCode: '+43',
        flag: '🇦🇹',
      ),
      CountryCode(
        name: 'Switzerland',
        code: 'CH',
        dialCode: '+41',
        flag: '🇨🇭',
      ),
      CountryCode(
        name: 'Portugal',
        code: 'PT',
        dialCode: '+351',
        flag: '🇵🇹',
      ),
    ],
    'Asia': [
      CountryCode(
        name: 'India',
        code: 'IN',
        dialCode: '+91',
        flag: '🇮🇳',
      ),
      CountryCode(
        name: 'China',
        code: 'CN',
        dialCode: '+86',
        flag: '🇨🇳',
      ),
      CountryCode(
        name: 'Japan',
        code: 'JP',
        dialCode: '+81',
        flag: '🇯🇵',
      ),
      CountryCode(
        name: 'South Korea',
        code: 'KR',
        dialCode: '+82',
        flag: '🇰🇷',
      ),
      CountryCode(
        name: 'Singapore',
        code: 'SG',
        dialCode: '+65',
        flag: '🇸🇬',
      ),
      CountryCode(
        name: 'Malaysia',
        code: 'MY',
        dialCode: '+60',
        flag: '🇲🇾',
      ),
      CountryCode(
        name: 'Indonesia',
        code: 'ID',
        dialCode: '+62',
        flag: '🇮🇩',
      ),
      CountryCode(
        name: 'Thailand',
        code: 'TH',
        dialCode: '+66',
        flag: '🇹🇭',
      ),
    ],
  };
  // Flat list of all countries for easy search
  late List<CountryCode> _allCountries;

  @override
  void initState() {
    super.initState();

    // Create a flat list of all countries
    _allCountries = [];
    _countriesByRegion.forEach((region, countries) {
      _allCountries.addAll(countries);
    });

    // Sort alphabetically for easy search
    _allCountries.sort((a, b) => a.name.compareTo(b.name));

    // Set initial selected country
    if (widget.initialCountryCode != null) {
      _selectedCountry = _allCountries.firstWhere(
        (country) => country.code == widget.initialCountryCode,
        orElse: () =>
            _allCountries.firstWhere((country) => country.code == 'US'),
      );
    } else {
      _selectedCountry =
          _allCountries.firstWhere((country) => country.code == 'US');
    }

    // Update the main controller with the dial code
    _updateMainController();

    // Add listener to update main controller when phone number changes
    _phoneNumberController.addListener(_updateMainController);
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_updateMainController);
    _phoneNumberController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateMainController() {
    // Combine country code and phone number
    widget.controller.text =
        "${_selectedCountry.dialCode} ${_phoneNumberController.text}";
  }

  void _selectCountry(CountryCode country) {
    safeSetState(() {
      _selectedCountry = country;
      _isCountryListOpen = false;
    });
    _updateMainController();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isCountryListOpen) ...[
            _buildCountrySelector(),
          ] else ...[
            _buildPhoneField(context),
          ],
        ],
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      controller: _phoneNumberController,
      focusNode: _focusNode,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
              fontFamily: 'Montserrat',
              letterSpacing: 0.0,
            ),
        hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
              fontFamily: 'Montserrat',
              letterSpacing: 0.0,
            ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).error,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).primary,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).error,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
        contentPadding:
            const EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 24.0),
        prefixIcon: GestureDetector(
          onTap: () {
            safeSetState(() {
              _isCountryListOpen = true;
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${_selectedCountry.flag} ${_selectedCountry.dialCode}",
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Montserrat',
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down),
                Container(
                  height: 24,
                  width: 1,
                  color: FlutterFlowTheme.of(context).alternate,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ],
            ),
          ),
        ),
      ),
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Montserrat',
            letterSpacing: 0.0,
          ),
    );
  }

  Widget _buildCountrySelector() {
    // Create a filtered map of countries based on search
    Map<String, List<CountryCode>> filteredCountriesByRegion() {
      if (_searchQuery.isEmpty) {
        return _countriesByRegion;
      }

      final lowercaseQuery = _searchQuery.toLowerCase();
      Map<String, List<CountryCode>> filtered = {};

      _countriesByRegion.forEach((region, countries) {
        final filteredCountries = countries.where((country) {
          return country.name.toLowerCase().contains(lowercaseQuery) ||
              country.dialCode.toLowerCase().contains(lowercaseQuery) ||
              country.code.toLowerCase().contains(lowercaseQuery);
        }).toList();

        if (filteredCountries.isNotEmpty) {
          filtered[region] = filteredCountries;
        }
      });

      // If no results in regions, show all matching results in a single category
      if (filtered.isEmpty) {
        List<CountryCode> allMatches = [];
        for (var country in _allCountries) {
          if (country.name.toLowerCase().contains(lowercaseQuery) ||
              country.dialCode.toLowerCase().contains(lowercaseQuery) ||
              country.code.toLowerCase().contains(lowercaseQuery)) {
            allMatches.add(country);
          }
        }

        if (allMatches.isNotEmpty) {
          filtered['Search Results'] = allMatches;
        }
      }

      return filtered;
    }

    final filteredCountries = filteredCountriesByRegion();

    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Country',
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    safeSetState(() {
                      _isCountryListOpen = false;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextFormField(
              style:
                  TextStyle(color: FlutterFlowTheme.of(context).primaryText),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search countries...',
                hintStyle: TextStyle(
                    color: FlutterFlowTheme.of(context)
                        .secondaryText), // Hint text color
                prefixIcon: Icon(Icons.search,
                    color: FlutterFlowTheme.of(context).primaryText), // Icon color
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).alternate),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).alternate),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).alternate),
                ),

                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: FlutterFlowTheme.of(context).primaryText),
                        onPressed: () {
                          _searchController.clear();
                          safeSetState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                safeSetState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredCountries.isEmpty
                ? Center(
                    child: Text(
                      'No countries found',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  )
                : DefaultTabController(
                    length: filteredCountries.length,
                    child: Column(
                      children: [
                        if (filteredCountries.length > 1)
                          TabBar(
                            isScrollable: true,
                            tabs: filteredCountries.keys.map((region) {
                              return Tab(text: region);
                            }).toList(),
                            labelColor: FlutterFlowTheme.of(context).primary,
                            unselectedLabelColor:
                                FlutterFlowTheme.of(context).secondaryText,
                          ),
                        Expanded(
                          child: filteredCountries.length == 1
                              ? _buildCountryList(
                                  filteredCountries.values.first,
                                  _selectedCountry,
                                )
                              : TabBarView(
                                  children:
                                      filteredCountries.entries.map((entry) {
                                    return _buildCountryList(
                                      entry.value,
                                      _selectedCountry,
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryList(
      List<CountryCode> countries, CountryCode selectedCountry) {
    return ListView.builder(
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        return ListTile(
          leading: Text(country.flag,
              style: TextStyle(
                  fontSize: 24,
                  color: FlutterFlowTheme.of(context).primaryText)),
          title: Text(country.name,
              style:
                  TextStyle(color: FlutterFlowTheme.of(context).primaryText)),
          subtitle: Text(country.dialCode,
              style:
                  TextStyle(color: FlutterFlowTheme.of(context).primaryText)),
          onTap: () => _selectCountry(country),
          selected: selectedCountry.code == country.code,
          selectedTileColor: FlutterFlowTheme.of(context).primaryText,
        );
      },
    );
  }
}

class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}
