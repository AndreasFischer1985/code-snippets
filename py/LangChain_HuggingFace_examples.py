##################################################################################
# Title: LangChain-Applications based on free open source models from HuggingFace
# Author: Andreas Fischer
# Date: April 15, 2023
##################################################################################

# Option 1: use local Huggingface-model
#---------------------------------------

if(False): # run the following code to download the model flan-t5-large from huggingface.co
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


# Option 3: use custom model (via API without API-token)
#--------------------------------------------------------

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


# Option 4: use a model from the llama-family (ggml-version)
#-----------------------------------------------------------

if(False): # run the following code to download a model like wizardLM-7B.ggml.q4_0.bin from huggingface.co
  l7b="https://huggingface.co/hlhr202/llama-7B-ggml-int4/resolve/main/ggml-model-q4_0.bin"
  l13b="https://huggingface.co/Drararara/llama-13B-ggml/resolve/main/ggml-model-q4_0.bin"   
  a7b="https://huggingface.co/hlhr202/alpaca-7B-ggml-int4/resolve/main/ggml-alpaca-7b-q4.bin"
  a13b="https://huggingface.co/Pi3141/alpaca-lora-13B-ggml/resolve/main/ggml-model-q4_0.bin"  
  o13b="https://huggingface.co/Black-Engineer/oasst-llama13b-ggml-q4/resolve/main/qunt4_0.bin" 
  g4a="https://huggingface.co/eachadea/ggml-gpt4all-7b-4bit/resolve/main/gpt4all-lora-quantized-ggml.bin" 
  k7b="https://huggingface.co/TheBloke/koala-7B-GPTQ-4bit-128g-GGML/resolve/main/koala-7B-4bit-128g.GGML.bin" 
  v7b="https://huggingface.co/eachadea/ggml-vicuna-7b-1.1/resolve/main/ggml-vicuna-7b-1.1-q4_0.bin"
  v13b="https://huggingface.co/eachadea/ggml-vicuna-13b-1.1/resolve/main/ggml-vicuna-13b-1.1-q4_0.bin"
  wiz="https://huggingface.co/TheBloke/wizardLM-7B-GGML/resolve/main/wizardLM-7B.ggml.q4_0.bin"
  weights=requests.get(wiz)
  with open("weights.bin","wb") as out_file:
    out_file.write(weights.content)
  
from llama_cpp import Llama
llamallm = Llama(model_path="./weights.bin")
output = llamallm("What is the meaning of life?", max_tokens=100, echo=True)
print(output)

from langchain.llms.base import LLM
from typing import Optional, List, Mapping, Any
from langchain import PromptTemplate, LLMChain
import requests
class CustomLLM(LLM):  
  def _call(self, prompt: str, stop: Optional[List[str]] = None) -> str:    
    print("***\n"+prompt+"\n***")
    output = llamallm(prompt, echo=False) #, stop=["Q:", "\n"], max_tokens=100,     
    return(output["choices"][0]["text"])
  @property
  def _llm_type(self) -> str:
    return "custom"
 
llm=CustomLLM()

  
# LangChain-Application: Simple Q&A-Bot
#---------------------------------------

from langchain import PromptTemplate, LLMChain
template = """Question: {question}
Answer: Let's think step by step."""
prompt = PromptTemplate(template=template, input_variables=["question"])
chain = LLMChain(llm=llm, verbose=True, prompt=prompt)
chain("What is the meaning of life?")


# LangChain-Application: Chatbot
#--------------------------------

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


# LangChain-Application: Sentence Embeddings
#--------------------------------------------

from langchain.embeddings import HuggingFaceInstructEmbeddings #sentence_transformers and InstructorEmbedding   
hf = HuggingFaceInstructEmbeddings(
  model_name="hkunlp/instructor-xl", #"/home/af/Documents/Py/Huggingface/hkunlp_instructor-xl",
  embed_instruction="Represent the document for retrieval: ",
  query_instruction="Represent the query for retrieval: "
)
text = "This is a test document."
text_result = hf.embed_query(text)
texts = ["This is a test document.","this is a document too."]
texts_result = hf.embed_documents(texts)


# LangChain-Application: Wikipedia-Agent
#---------------------------------------- 

from langchain.agents import Tool, initialize_agent
from langchain.utilities import WikipediaAPIWrapper #,TextRequestsWrapper,PythonREPL,BashProcess
tools=[
  Tool(
    name="Search",
    func=WikipediaAPIWrapper().run,
    description="Run Wikipedia search and get page summaries"
  )
]
agent = initialize_agent(tools, llm, agent="zero-shot-react-description", verbose=True)
agent("What is the meaning of life?")


# LangChain-Application: Vectorstore-Agent
#------------------------------------------

from langchain.vectorstores import Chroma
from langchain.text_splitter import CharacterTextSplitter
from langchain.chains import RetrievalQA
from langchain.llms.base import LLM
from typing import Optional, List, Mapping, Any
from langchain import PromptTemplate, LLMChain
from pathlib import Path
relevant_parts = []
for p in Path(".").absolute().parts:
    relevant_parts.append(p)
    if relevant_parts[-3:] == ["langchain", "docs", "modules"]:
        break

doc_path = str(Path(*relevant_parts) / "state_of_the_union.txt")

from langchain.document_loaders import TextLoader
loader = TextLoader(doc_path)
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(documents)

from langchain.embeddings import HuggingFaceInstructEmbeddings 
hf = HuggingFaceInstructEmbeddings(
  model_name="hkunlp/instructor-large", 
  embed_instruction="Represent the document for retrieval: ",
  query_instruction="Represent the query for retrieval: "
)
embeddings = hf
docsearch = Chroma.from_documents(texts, embeddings, collection_name="state-of-union")
state_of_union = RetrievalQA.from_chain_type(llm=llm, chain_type="stuff", retriever=docsearch.as_retriever())

from langchain.document_loaders import WebBaseLoader
loader = WebBaseLoader("https://beta.ruff.rs/docs/faq/")
docs = loader.load()
ruff_texts = text_splitter.split_documents(docs)
ruff_db = Chroma.from_documents(ruff_texts, embeddings, collection_name="ruff")
ruff = RetrievalQA.from_chain_type(llm=llm, chain_type="stuff", retriever=ruff_db.as_retriever())

from langchain.agents import initialize_agent, Tool
tools = [
    Tool(
        name = "State of Union QA System",
        func=state_of_union.run,
        description="useful for when you need to answer questions about the most recent state of the union address. Input should be a fully formed question."
    ),
    Tool(
        name = "Ruff QA System",
        func=ruff.run,
        description="useful for when you need to answer questions about ruff (a python linter). Input should be a fully formed question."
    ),
]
agent = initialize_agent(tools, llm, agent="zero-shot-react-description", verbose=True)
agent.run("What did biden say about ketanji brown jackson is the state of the union address?")
agent.run("Why use ruff over flake8?")
