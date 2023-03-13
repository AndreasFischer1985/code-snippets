#!/bin/bash

YOUR_API_KEY="sk-xxx"

# Have a chat with Guybrush Threepwood, the mighty pirate!
curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -d '{
  "model": "gpt-3.5-turbo",
  "messages": [
	{"role": "system", "content": "You are Guybrush Threepwood, mighty pirate."},
	{"role": "user", "content": "Hello!"}]}'

# Generate Magic Cards according to a specified schema in JSON format
curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -d '{
  "model": "gpt-3.5-turbo",
  "messages": [
	{"role": "system", "content": "You are an assistant who works as a Magic: The Gathering card designer. Create cards that are in the following card schema and JSON format. OUTPUT MUST FOLLOW THIS CARD SCHEMA AND JSON FORMAT. DO NOT EXPLAIN THE CARD. The output must also follow the Magic \"color pie\".\n\n{\"name\":\"Harbin, Vanguard Aviator\",\"manaCost\":\"{W}{U}\",\"type\":\"Legendary Creature — Human Soldier\",\"text\":\"Flying\nWhenever you attack with five or more Soldiers, creatures you control get +1/+1 and gain flying until end of turn.\",\"flavorText\":\"\\\"Yotia is my birthright, father. Let me fight for it.\\\"\",\"pt\":\"3/2\",\"rarity\":\"rare\"}"},
	{"role": "user", "content": "Create a Magic Card on Pikachu!"}],
  "temperature": 0
}'

# Use ChatGPT for sentiment analysis
curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -d '{
  "model": "gpt-3.5-turbo",
  "messages": [
	{"role": "system", "content": "You are an emotionally intelligent assistant. Classify the sentiment of the user'"'"'s text with ONLY ONE OF THE FOLLOWING EMOTIONS:\n- \"happy\",\n- \"sad\",\n- \"angry\",\n- \"tired\",\n- \"very happy\",\n- \"very sad\",\n- \"very angry\",\n- \"very tired\".  After classifying a text, respond with \"<|DONE|>\"."},
	{"role": "user", "content": "I just bought a new iPhone!"}],
  "temperature": 0,
  "max_tokens": 10
}'

# Use text-davinci-003 for text-completion
curl https://api.openai.com/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -d '{
  "model": "text-davinci-003",
  "prompt": "Two times two times two equals",
  "temperature": 0.7,
  "max_tokens": 256,
  "top_p": 1,
  "frequency_penalty": 0,
  "presence_penalty": 0
}'

# Get text embedding
curl https://api.openai.com/v1/embeddings \
  -X POST \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"input": "The food was delicious and the waiter...",
       "model": "text-embedding-ada-002"}'

# Generate image
curl https://api.openai.com/v1/images/generations \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -d '{
  "prompt": "A cute baby sea otter",
  "n": 2,
  "size": "1024x1024"
}'

# Edit image
curl https://api.openai.com/v1/images/edits \
  -H 'Authorization: Bearer $YOUR_API_KEY' \
  -F image='@otter.png' \
  -F mask='@mask.png' \
  -F prompt="A cute baby sea otter wearing a beret" \
  -F n=2 \
  -F size="1024x1024"

# Vary image
curl https://api.openai.com/v1/images/variations \
  -H 'Authorization: Bearer $YOUR_API_KEY' \
  -F image='@otter.png' \
  -F n=2 \
  -F size="1024x1024"

# Get list of models
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $YOUR_API_KEY"

# Get info on specific model
curl https://api.openai.com/v1/models/text-davinci-003 \
  -H "Authorization: Bearer $YOUR_API_KEY"

curl https://api.openai.com/v1/files \
  -H 'Authorization: Bearer YOUR_API_KEY'

curl https://api.openai.com/v1/files \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -F purpose="fine-tune" \
  -F file='@mydata.jsonl'

curl https://api.openai.com/v1/fine-tunes \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -d '{
  "training_file": "file-XGinujblHPwGLSztz8cPS8XY"
}'

curl https://api.openai.com/v1/fine-tunes \
  -H 'Authorization: Bearer $YOUR_API_KEY'

