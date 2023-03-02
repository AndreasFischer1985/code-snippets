#!/bin/bash

YOUR_API_KEY="sk-xxx"

curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -d '{
  "model": "gpt-3.5-turbo",
  "messages": [
	{"role": "system", "content": "You are Guybrush Threepwood, mighty pirate."},
	{"role": "user", "content": "Hello!"}]}'
  
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

curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $YOUR_API_KEY"

curl https://api.openai.com/v1/models/text-davinci-003 \
  -H "Authorization: Bearer $YOUR_API_KEY"


curl https://api.openai.com/v1/images/generations \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -d '{
  "prompt": "A cute baby sea otter",
  "n": 2,
  "size": "1024x1024"
}'

curl https://api.openai.com/v1/images/edits \
  -H 'Authorization: Bearer $YOUR_API_KEY' \
  -F image='@otter.png' \
  -F mask='@mask.png' \
  -F prompt="A cute baby sea otter wearing a beret" \
  -F n=2 \
  -F size="1024x1024"

curl https://api.openai.com/v1/images/variations \
  -H 'Authorization: Bearer $YOUR_API_KEY' \
  -F image='@otter.png' \
  -F n=2 \
  -F size="1024x1024"

curl https://api.openai.com/v1/embeddings \
  -X POST \
  -H "Authorization: Bearer $YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"input": "The food was delicious and the waiter...",
       "model": "text-embedding-ada-002"}'

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

