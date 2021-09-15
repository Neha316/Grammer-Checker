


import requests
from bs4 import BeautifulSoup
from flask import Flask, request
import language_tool_python
import json
import re
from nltk.tokenize import sent_tokenize, word_tokenize


import random
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import nltk
import warnings
warnings.filterwarnings('ignore')

tool = language_tool_python.LanguageTool('en-US')
app = Flask(__name__)

@app.route('/grammar', methods = ['GET'])
def grammar():
    text = request.args.get('text')
    corrections = tool.check(text)
    required_corrections = [[i.offset, i.errorLength, i.replacements[:5], i.ruleIssueType] for i in corrections]
    return json.dumps(required_corrections)
    
@app.route('/synonyms', methods = ['GET'])
def synonyms():
    text = request.args.get('text')
    stop_words=['as', "that'll", 'this', "you'd", 'under', 'other', 'once', "hadn't", "shouldn't", 'ourselves', 'above', 'if', 'ma', 'ain', "aren't", 'himself', 'itself', 'aren', 'by', "you've", 'too', 'hadn', 'did', 'over', 'm', 'i', "needn't", "wouldn't", 'but', 'have', 'won', 'wouldn', 'herself', 'of', 'such', 'needn', "weren't", 'her', 'an', 'and', 'yourself', 'there', 'them', "didn't", 'my', 'it', 'myself', 'for', 'does', 'which', 'y', 'only', "mustn't", 'theirs', 'so', 'a', 'into', 'couldn', "you'll", 'against', 'below', "won't", "don't", 'while', 'he', 'any', "you're", "it's", 'in', 'didn', 'who', 'before', 'on', 'him', 'what', 'their', 'at', 'how', 'she', 'these', 'here', 'between', "wasn't", 'during', 'because', 'through', 'about', 'that', 'will', 're', 'when', 'had', 'not', 'mustn', 'most', 'themselves', 'then', 'same', "couldn't", "isn't", 'just', 'wasn', 'has', 'than', "doesn't", 'are', 'hasn', 'its', 'few', 'further', 't', "hasn't", 'do', 'up', 'those', 'yourselves', 'down', 'each', 'am', 'with', 'haven', 've', 'both', 'some', 's', 'they', 'your', 'we', 'very', "should've", 'me', 'again', 'after', 'ours', 'out', 'you', 'own', 'o', 'being', 'or', "haven't", 'why', 'don', 'doesn', 'hers', 'isn', 'mightn', 'no', 'll', 'to', 'doing', 'having', 'd', 'were', 'is', 'off', 'weren', "she's", 'yours', 'should', 'our', "shan't", 'now', 'been', 'whom', 'be', 'the', 'more', 'can', 'shouldn', 'from', 'until', 'his', 'was', "mightn't", 'shan', 'nor', 'all', 'where']
    #print(stop_words)
    #text=This is so called depression,caused due to loneliness.So do not think too much of anything
    text = text.lower()
    text = text.replace(',', ' ')
    text = text.replace('.', ' ')
    text = text.replace(':', ' ')
    tokenized = sent_tokenize(text)
    for sen in tokenized:
        wordList = word_tokenize(sen)
        wordList = [w for w in wordList if not w in stop_words]
    final_list=[]
    for word in wordList:
        lis=[]
        url = "https://www.thesaurus.com/browse/"+word+"?s=t"
        html_text = requests.get(url).text
        soup = BeautifulSoup(html_text,'lxml')
        meanings = soup.find("div",{"id":'meanings'})
        if meanings != None:
            xyz =meanings.find("ul")
            synonyms=[]
            for syn in xyz:
                if(syn.find('a')!=None):
                    #synonyms.append(syn.find("a",attrs={'bgcolor':'rgb(244, 71, 37)'}).text)
                    synonyms.append(syn.find("a").text.strip())
            a=re.search(word,text).start()
            w=len(word)
            lis=[a,w,synonyms[0:5]]
            final_list.append(lis)
            return json.dumps(final_list)
        else:
            return json.dumps([])

f=open('chatbot.txt','r',errors = 'ignore')
raw=f.read()# converts to lowercase



sent_tokens = nltk.sent_tokenize(raw)  # converts to list of sentences 

lemmer = nltk.stem.WordNetLemmatizer()
def LemTokens(tokens):
    return [lemmer.lemmatize(token) for token in tokens]
def LemNormalize(text):
    return LemTokens([re.sub(r'[^a-zA-Z]', " ",i ) for i in nltk.word_tokenize(text.lower())]) 


GREETING_INPUTS = ("hello", "hi","hlo", "greetings", "sup", "what's up","hey")
GREETING_RESPONSES = ["hi", "hey", "hi there", "hello", "I am glad! You are talking to me"]
def greeting(sentence): 
    for word in sentence.split():
        if word.lower() in GREETING_INPUTS:
            return random.choice(GREETING_RESPONSES)


@app.route('/words', methods = ['GET'])
def words():
    word = request.args.get('text')
    url = "https://www.thesaurus.com/browse/"+word+"?s=t"
    html_text = requests.get(url).text
    soup = BeautifulSoup(html_text,'lxml')
    meanings = soup.find("div",{"id":'meanings'})
    antonyms = soup.find("div",{"id":'antonyms'})
    if(meanings!=None):
        xyz =meanings.find("ul")
        synonyms=[]
        for syn in xyz:
           if(syn.find('a')!=None):
              synonyms.append(syn.find("a").text)
    else:
        synonyms=[]
        
    if(antonyms!=None):
        abc = antonyms.find("ul")
        antonyms=[]
        for ant in abc:
            if(ant.find('a')!=None):
                antonyms.append(ant.find("a").text)
    else:
        antonyms=[]
    
    words=[synonyms[0:5],antonyms[0:5]]
    return json.dumps(words)

@app.route('/definitions', methods = ['GET'])
def definitions():
    word = request.args.get('text')
    url = "https://www.dictionary.com/browse/"+word+"?s=t"
    html_text = requests.get(url).text
    soup = BeautifulSoup(html_text,'lxml')
    segment = soup.find("div",{"class":'css-1avshm7 e16867sm0'})
    section = segment.find_all("section",{"class":'css-pnw38j e1hk9ate4'})
    #var = soup.find_all("span",{"class":'luna-pos'})
    definition = segment.find_all("div",{"class":'css-1uqerbd e1hk9ate0'})
    count=0
    a=0
    dic_lis=[]
    for n in range(len(definition)):
        fin_lis=[]
        nature = section[n].find("span",{"class":'luna-pos'}).text
        fin_lis.append(nature)
        data = definition[n].find_all("span",{"class":'one-click-content css-ibc84h e1q3nk1v1'})
        italic_lis=[]
        value=[]
        for l in range(len(data)):
            if(data[l].parent.name=="li"):
                value.append(data[l].parent.parent.parent["value"])
            else:
                value.append(data[l].parent["value"])
        value=set(value)
        sen_lis=['' for i in range(len(value))]
        italic_lis=['' for i in range(len(value))]
        k=0
        for j in range(len(data)):
            if(data[j].parent.name=="li"):
                k=int(data[j].parent.parent.parent["value"])
            else:
                 k=int(data[j].parent["value"])
            if(data[j].parent.name!="li"):
                 sen_lis[k-count-1]=sen_lis[k-count-1]+data[j].text
            else:
                 sen_lis[k-count-1]=data[j].parent.text
            if(data[j].find('span',{"class":'luna-example italic'})!=None):
                 italic_lis[k-count-1]=data[j].find('span',{"class":'luna-example italic'}).text
            else:
                 italic_lis[k-count-1]=""
            if(len(italic_lis[k-count-1])!=0):
                 sen_lis[k-count-1] = sen_lis[k-count-1][:-(len(italic_lis[k-count-1]))]
        if(len(sen_lis)>=3):
            a=3
        else:
            a=len(sen_lis)
        for i in range(a):
            out_lis=[sen_lis[i],italic_lis[i]]
            fin_lis.append(out_lis)
        count = count+len(sen_lis)
        dic_lis.append(fin_lis)          
    return json.dumps(dic_lis)

def response(user_response):
    robo_response=''
    sent_tokens.append(user_response)
    TfidfVec = TfidfVectorizer(tokenizer=LemNormalize, stop_words='english')
    tfidf = TfidfVec.fit_transform(sent_tokens)
    vals = cosine_similarity(tfidf[-1], tfidf)
    idx=vals.argsort()[0][-2]
    flat = vals.flatten()
    flat.sort()
    req_tfidf = flat[-2]
    if(req_tfidf==0):
        robo_response=robo_response+"I am sorry! I don't understand you"
        return robo_response
    else:
        robo_response = robo_response+sent_tokens[idx]
        return robo_response


@app.route('/chatbot', methods = ['GET'])
def askQuestions():
    user_response = request.args.get('text')
    user_response=user_response.lower()
    if(user_response!='bye'):
        if(user_response=='thanks' or user_response=='thank you' or user_response=='tq' ):
            
            return "You are welcome.."
        else:
            if(greeting(user_response)!=None):
                return greeting(user_response)
            else:
                a =response(user_response)
                sent_tokens.remove(user_response)
                return a
    else:
        
        return "Bye! take care..we will be happy to meet you again"


if __name__ == '__main__':
    app.run()















