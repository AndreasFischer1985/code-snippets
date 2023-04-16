##################################################################################
# Title: LangChain-Applications based on free open source models from HuggingFace
# Author: Andreas Fischer
# Date: April 15, 2023
##################################################################################

# Option 1: use local Huggingface-model
#---------------------------------------

if(False):
  from transformers import pipeline
  model= pipeline(model="google/flan-t5-large") #'text2text-generation'
  model.save_pretrained("~/flan-t5-large")

from langchain import PromptTemplate, LLMChain
from langchain.llms import HuggingFacePipeline
llm = HuggingFacePipeline.from_model_id(model_id="~/flan-t5-large", task="text2text-generation", model_kwargs={"temperature":1e-10})

template="""
{input}
"""
prompt = PromptTemplate(input_variables=["input"], template=template)
chain = LLMChain(llm=llm, verbose=True, prompt=prompt)
chain("What is the meaning of life?")


# Option 2: use Huggingface Inference-API
#-----------------------------------------

import os
os.environ["HUGGINGFACEHUB_API_TOKEN"]=hf_token # replace hf_token with your HuggingFace API-token 
from langchain import PromptTemplate, LLMChain
from langchain.llms import HuggingFaceHub
llm = HuggingFaceHub(repo_id="google/flan-t5-large", model_kwargs={"temperature":1e-10})

template="""
{input}
"""
prompt = PromptTemplate(input_variables=["input"], template=template)
chain = LLMChain(llm=llm, verbose=True, prompt=prompt)
chain("What is the meaning of life?")


# Option 3: use custom model
#----------------------------

from langchain.llms.base import LLM
from typing import Optional, List, Mapping, Any
from langchain import PromptTemplate, LLMChain
import requests
class CustomLLM(LLM):  
  def _call(self, prompt: str, stop: Optional[List[str]] = None) -> str:
    prompt_length = len(prompt)
    model_id = "google/flan-t5-xl" 
    params={"max_length":200, "length_penalty":2, "num_beams":16, "early_stopping":True}
    url = f"https://api-inference.huggingface.co/models/{model_id}"
    post = requests.post(url, json={"inputs":prompt, "parameters":params})
    return post.json()[0]["generated_text"]
    #return response[prompt_length:] # only return newly generated tokens
  @property
  def _llm_type(self) -> str:
    return "custom"

llm=CustomLLM()

template="""
{input}
"""
prompt = PromptTemplate(input_variables=["input"], template=template)
chain = LLMChain(llm=llm, verbose=True, prompt=prompt)
chain("What is the meaning of life?")


# LangChain-Application: Q&A-Bot
#----------------------------------

from langchain import PromptTemplate, LLMChain
template = """Question: {question}
Answer: Let's think step by step."""
prompt = PromptTemplate(template=template, input_variables=["question"])
chain = LLMChain(llm=llm, verbose=True, prompt=prompt)
chain("What is the meaning of life?")


# LangChain-Application: Chatbot
#----------------------------------

from langchain.chains import ConversationChain
from langchain.chains.conversation.memory import ConversationBufferMemory, ConversationSummaryMemory, ConversationBufferWindowMemory, ConversationSummaryBufferMemory
conversation = ConversationChain(
  llm=llm,
  verbose=True,
  #memory=ConversationBufferMemory()
  #memory=ConversationSummaryMemory(llm=llm)
  memory=ConversationBufferWindowMemory(k=1)
  #memory=ConversationSummaryBufferMemory(llm=llm,max_token_limit=100)

)
conversation.predict(input="Hi there!")
conversation.predict(input="Tell me about transformers!")
