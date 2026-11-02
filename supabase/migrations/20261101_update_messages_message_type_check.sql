-- Migration: update_messages_message_type_check_add_action_types.sql
-- Description: Updates messages_message_type_check to allow action types ('mate_request', 'citadel_fight', 'citadel_fight_result', 'citadel_attack')
-- Date: 2026-11-01

ALTER TABLE messages DROP CONSTRAINT IF EXISTS messages_message_type_check;

ALTER TABLE messages ADD CONSTRAINT messages_message_type_check 
CHECK (
  (message_type IS NULL) OR 
  (message_type = ANY (ARRAY[
    'text'::text, 
    'voice'::text, 
    'image'::text, 
    'file'::text, 
    'gallery'::text, 
    'video'::text, 
    'thought'::text, 
    'tool'::text, 
    'pocket_talk_request'::text, 
    'snap'::text, 
    'document'::text, 
    'course'::text, 
    'system'::text, 
    'status_mention'::text, 
    'robot_voice'::text,
    'mate_request'::text,
    'citadel_fight'::text,
    'citadel_fight_result'::text,
    'citadel_attack'::text
  ]))
);

