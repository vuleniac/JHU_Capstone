####### RESOURCES ######

##REQURED

library(stringr)
library(stringi)
library(dplyr)
library(reshape2)
library(tm)
library(RWeka)
library(slam)
library(stylo)
library(hash)

##DATA

profanity <- readLines("./DATA/bad-words.txt")

load(file= "./DATA/HASH.rda")
load(file= "./DATA/h2.rda")
load(file= "./DATA/h3.rda")
load(file= "./DATA/h4.rda")

##FUNCTIONS

#TEXT NORMALIZER

normText <- function(corpus, toLower=T, rmPunctuation=T, rmNumbers=T, rmVulgar=character(), rmGraphs=T, strpSpace=T, rmStopW=T, stem=F){
    
    corpus <- Corpus(VectorSource(as.vector(corpus)))
    corpus <- tm_map(corpus,content_transformer(function(x) iconv(x,'utf8','ascii',sub='')))
    if(rmGraphs==T){corpus <- tm_map(corpus,content_transformer(function(x) str_replace_all(x,"[^[:graph:]]", " ")))}
    if(stem==T){corpus <- tm_map(corpus,stemDocument)}
    if(toLower==T){corpus <- tm_map(corpus,content_transformer(tolower))}
    if(rmNumbers==T){corpus <- tm_map(corpus,removeNumbers)}
    if(rmStopW==T){corpus <- tm_map(corpus, removeWords, stopwords("english"))}
    if(rmPunctuation==T){corpus <- tm_map(corpus,removePunctuation)}
    if(length(rmVulgar)>0){corpus <- tm_map(corpus,removeWords,rmVulgar)}
    if(strpSpace==T){corpus <- tm_map(corpus,stripWhitespace)}
    corpus <- data.frame(text=unlist(sapply(corpus, `[`, "content")), stringsAsFactors=F)[1,"text"]
    corpus <- trimws(corpus)
}

#nGram HASH FINDER

findGram <- function(x) {
    
    text <- normText(x, rmVulgar = profanity)
    
    text4<- word(text, start =-3, end = -1)
    text3<- word(text, start =-2, end = -1)
    text2<- word(text, start =-1, end = -1)
    
    tic <- 0
    
    if(!is.na(text2) && text2!=""){
        if(!is.null(h2[[text2]])){
            found2 <- as.numeric(h2[[text2]]) ; tic <- 2
        }else{
            found2 <- NA
        }
    } else {
        found2 <- NA
    }
    
    if(!is.na(text3)){
        if(!is.null(h3[[text3]])){
            found3 <- as.numeric(h3[[text3]]) ; tic <- 3
        }else{
            found3 <- NA
        }
    } else {
        found3 <- NA
    }
    
    if(!is.na(text4)){
        if(!is.null(h4[[text4]])){
            found4 <- as.numeric(h4[[text4]]) ; tic <- 4
        }else{
            found4 <- NA
        }
    } else {
        found4 <- NA
    }
    
    found <- list()
    for(i in 1:4){
        if(i==1){
            found[[i]] <- tic
        }else{
            found[[i]] <- as.numeric(get(paste("found",i,sep="")))
        }
    }
    
    found
    
}

#SUGGESTION GENERATOR - BACK-OFF ALGORITHM

suggestGram <- function(x,n=6) {
    
    found <- findGram(x)
    
    if(found[[1]]==0){
        
        suggestions <- "No Suggestions"
        
    }else{
        
        suggest <- data.frame()
        
        for(i in 2:found[[1]]){
            
            y<-found[[i]]
            tempdf<- data.frame(cbind(i,names(HASH[[i-1]][y]),stri_split_regex(t(stri_split_regex(HASH[[i-1]][y], pattern = ", ", simplify = T)), pattern = "#", simplify = T)), stringsAsFactors = F)
            tempdf[,4]<- as.numeric(tempdf[,4])
            tempdf[,1]<- as.numeric(tempdf[,1])
            suggest<- rbind(suggest,tempdf)
            
        }
        suggest <- suggest[order(suggest[,1],suggest[,4],decreasing=T),]
        names(suggest)<- c("nGram_#", "MATCH", "Suggestion", "Freq")
        suggestions <- unique(suggest[,3])
        suggestions <- suggestions[!is.na(suggestions)]
        if(length(suggestions)>=n){
            suggestions <- suggestions[1:n]
        }else{
            suggestions <- suggestions
        }
    }
    
    suggestions
}