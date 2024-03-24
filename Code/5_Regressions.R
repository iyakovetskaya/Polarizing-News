library(fixest)
library(dplyr)
library(kableExtra)
library(xtable)

mydata <- read.csv('../Data/panel_polarization_full.csv')
#names(mydata)[25:64]#topics

# Adding columns:
mydata<-mydata %>%
  mutate(rankef_diff25 = case_when(
    rank_facebook == 0 & rank_emailed != 0 ~ rank_emailed - 25,
    rank_facebook != 0 & rank_emailed == 0 ~ 25 - rank_facebook,
    rank_facebook != 0 & rank_emailed != 0 ~ rank_emailed - rank_facebook,
    TRUE ~ 0 
  ), rankef_diff30 = case_when(
    rank_facebook == 0 & rank_emailed != 0 ~ rank_emailed - 30,
    rank_facebook != 0 & rank_emailed == 0 ~ 30 - rank_facebook,
    rank_facebook != 0 & rank_emailed != 0 ~ rank_emailed - rank_facebook,
    TRUE ~ 0 
  ), rankef_diff35 = case_when(
    rank_facebook == 0 & rank_emailed != 0 ~ rank_emailed - 35,
    rank_facebook != 0 & rank_emailed == 0 ~ 35 - rank_facebook,
    rank_facebook != 0 & rank_emailed != 0 ~ rank_emailed - rank_facebook,
    TRUE ~ 0 
  ), egreater = case_when(
    rank_emailed>rank_facebook & rank_facebook!= 0 ~ 1,
    rank_facebook != 0 & rank_emailed == 0 ~ 1,
    TRUE ~ 0)
  )


mydata$word_count = (mydata$word_count-mean(mydata$word_count))/sd(mydata$word_count)
mydata$snippet_len = (mydata$snippet_len-mean(mydata$snippet_len))/sd(mydata$snippet_len)
mydata$t_num<-mydata$t_after_release
mydata$date_num<-mydata$date_id
cats <- c("date_id","t_after_release", "print_section", "section_name", "news_desk") #Indicators for other covariates
mydata[ ,cats] <- lapply(mydata[ ,cats], as.factor)

topics <- paste("topic", 1:39, sep="_")
#Name all topics
topic_names_raw<-c('Israel', 'Architecture', 'World News', 'Food', 'Joe Biden', 'Elections',
                   'Emotions and Feelings', 'Music/Movies', 'Science', 'Supreme Court and Judicial System',
                   'Black Lives Matter', 'Books', 'Real Estate', 'New York City', 'Public Health and Medicine',
                   'Coronavirus Pandemic', 'Pets and Animals', 'Sports', 'Russia', "Women's Issues, Sexual Harassment",
                   'Judaism', 'Politics', 'Nature', 'Power, Energy Supply, and Climate',
                   'China, India, International Travel', 'Education, School System', 'American Military',
                   'Business', 'Family', 'Christianity and Church', 'Political Investigations',
                   'Covid Protection', 'Donald Trump', 'Horse Racing and Farms', 'Health Research, Lifestyle Advice',
                   'Covid Vaccine', 'Money, Personal Finance', 'Racial Identity and History',
                   'Art, Planes', 'Social Media') #40: 'Social media'

topic_names<-topic_names_raw
names(topic_names) <- paste("topic", 1:40, sep="_")


#-----Main regressions: Table 4 -----

#diff in ranks
fla1<-as.formula(paste("rankef_diff25 ~ ", "t_num  +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print + gpt_number +", 
                       paste(topics, collapse= "+"))) 

reg1 <- feols( fml = fla1, data = mydata, cluster ='date_id') ##vcov="HC1",


#Binary dependent variable
fla2<-as.formula(paste("egreater ~ ", "t_num +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print + gpt_number +", 
                      paste(topics, collapse= "+"))) 

reg2 <- feols(fml = fla2, data = mydata, cluster ='date_id',
)

etable(reg1, reg2, drop=c("section_name", "print_section", "date_id[[:digit:]]"), title="Regressions", label="Regressions",
       extralines=list("-Section_name"=c("Yes", "Yes"),
                       "_Sub-sample"=c("All", "All")),
       order=c('gpt_number', '%topic_29', '%topic_22', '%topic_7', '%topic_16', '%topic_12', 
               '%topic_2', '%topic_37', '%topic_14', '%topic_8', '%topic_35', 
               '%topic_23', '%topic_11', '%topic_20', '%topic_33', '%topic_6', 
               '%topic_5', '%topic_31', '%topic_15', '%topic_38', '%topic_28', 
               '%topic_40', '%topic_26', '%topic_10', '%topic_4', '%topic_3', 
               '%topic_27', '%topic_19', '%topic_36', '%topic_25', '%topic_13', 
               '%topic_24', '%topic_18', '%topic_39', '%topic_9', '%topic_32', 
               '%topic_1', '%topic_30', '%topic_34', '%topic_17', '%topic_21', 
               "word_count", "headline_main_len", "snippet_len", "polarity_full_text" ,"print"),
       dict=topic_names, digits='r3', family=TRUE, tex=TRUE, se.below=FALSE) #


#write.csv(summary(reg1)$coefficients,file="reg_polar_main1_coef.csv")

#-----Appendix: Table A6 -----

# rankef_diff with 30 and 35

fla30<-as.formula(paste("rankef_diff30 ~ ", "t_num  +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print + gpt_number +", 
                        paste(topics, collapse= "+"))) 
fla35<-as.formula(paste("rankef_diff35 ~ ", "t_num  +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print + gpt_number +", 
                        paste(topics, collapse= "+"))) 

reg30 <- feols( fml = fla30, data = mydata, cluster ='date_id')
reg35 <- feols( fml = fla35, data = mydata, cluster ='date_id')

# Emotions
#names(mydata)[93:98]

fla_e<-as.formula(paste("rankef_diff25 ~ ", "LIWC_affect + LIWC_posemo + LIWC_negemo + 
                      LIWC_anx + LIWC_anger + LIWC_sad + t_num  +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print + gpt_number +", 
                      paste(topics, collapse= "+"))) 

reg_e <- feols( fml = fla_e, data = mydata, cluster ='date_id') 


#no LDA:
fla0<-as.formula("rankef_diff25 ~ t_num  +t_num^2+ word_count +  headline_main_len +
                      snippet_len + section_name + print + gpt_number")

reg0 <- feols( fml = fla0, data = mydata, cluster ='date_id')

etable(reg30, reg35, reg_e, reg0, drop=c("section_name", "print_section", "t[[:digit:]]", "date_id[[:digit:]]"), title="Regressions", label="Regressions",
       extralines=list("-Section_name"=c("Yes", "Yes", "Yes", "Yes"),
                       "-Days after release"=c("Yes", "Yes", "Yes", "Yes"),
                       "_Sub-sample"=c("All_ranked", "All_ranked", "All_ranked", "All_ranked")),
       order=c('gpt_number', '%topic_29', '%topic_22', '%topic_7', '%topic_16', '%topic_12', 
               '%topic_2', '%topic_37', '%topic_14', '%topic_8', '%topic_35', 
               '%topic_23', '%topic_11', '%topic_20', '%topic_33', '%topic_6', 
               '%topic_5', '%topic_31', '%topic_15', '%topic_38', '%topic_28', 
               '%topic_40', '%topic_26', '%topic_10', '%topic_4', '%topic_3', 
               '%topic_27', '%topic_19', '%topic_36', '%topic_25', '%topic_13', 
               '%topic_24', '%topic_18', '%topic_39', '%topic_9', '%topic_32', 
               '%topic_1', '%topic_30', '%topic_34', '%topic_17', '%topic_21', 
               "word_count", "headline_main_len", "snippet_len", "polarity_full_text","print"),
       dict=topic_names, digits='r3', family=TRUE, tex=TRUE, se.below=FALSE) #



#-----Appendix: Table A7 -----

mydata<-mydata %>%
  mutate(
    T_elect = case_when(
    actual_date>='2020-12-01' ~ 1,
    actual_date<'2020-11-01' ~ 0,
    TRUE ~ 2 #exclude november
  ))

#exclude november
mydata_int<-mydata[!mydata$T_elect==2,]


fla_int1<-as.formula(paste("rankef_diff25 ~ ", "t_num  +t_num^2+ word_count +  headline_main_len +
                      snippet_len + section_name + print + gpt_number + T_elect + I(T_elect*gpt_number) + ",
                          paste(topics, collapse= "+")))

reg_int1 <- feols( fml = fla_int1, data = mydata_int, cluster ='date_id')


fla_int2<-as.formula(paste("egreater ~ ", "t_num  +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print + gpt_number + T_elect + I(T_elect*gpt_number) + ", 
                          paste(topics, collapse= "+"))) 

reg_int2 <- feols( fml = fla_int2, data = mydata_int, cluster ='date_id')

etable(reg_int1,reg_int2, drop=c("section_name", "print_section", "date_id[[:digit:]]"), title="Regressions", label="Regressions",
       order=c('gpt_number', 'T_elect', 'I(T_elect * gpt_number)', '%topic_29', '%topic_22', '%topic_7', '%topic_16', '%topic_12', 
               '%topic_2', '%topic_37', '%topic_14', '%topic_8', '%topic_35', 
               '%topic_23', '%topic_11', '%topic_20', '%topic_33', '%topic_6', 
               '%topic_5', '%topic_31', '%topic_15', '%topic_38', '%topic_28', 
               '%topic_40', '%topic_26', '%topic_10', '%topic_4', '%topic_3', 
               '%topic_27', '%topic_19', '%topic_36', '%topic_25', '%topic_13', 
               '%topic_24', '%topic_18', '%topic_39', '%topic_9', '%topic_32', 
               '%topic_1', '%topic_30', '%topic_34', '%topic_17', '%topic_21', 
               "word_count", "headline_main_len", "snippet_len", "polarity_full_text" ,"print"),
       dict=topic_names, digits='r3', family=TRUE, se.below=FALSE, tex=TRUE) #tex=TRUE



#-----Main text: Table 5 -----

combined_table <- bind_rows(
  mydata_int %>%
    filter(rank_emailed != 0) %>%
    group_by(T_elect) %>%
    summarize(sample = "emailed", mean_polar = mean(gpt_number)),
  
  mydata_int %>%
    filter(rank_facebook != 0) %>%
    group_by(T_elect) %>%
    summarize(sample = "facebook", mean_polar = mean(gpt_number))
)

latex_table <- xtable(combined_table, caption = "Combined Table", label = "tab:combined")

# Print or save the LaTeX code
print(latex_table, include.rownames = FALSE)  # Set include.rownames to TRUE if you want row names

#T-tests
t.test(gpt_number ~ T_elect, data = mydata_int[mydata_int$rank_facebook != 0,])$statistic
t.test(gpt_number ~ T_elect, data = mydata_int[mydata_int$rank_emailed != 0,])$statistic
t.test(mydata_int[(mydata_int$T_elect==1 & mydata_int$rank_emailed != 0),]$gpt_number, 
       mydata_int[(mydata_int$T_elect==1 & mydata_int$rank_facebook != 0),]$gpt_number, var.equal = FALSE)$statistic
t.test(mydata_int[(mydata_int$T_elect==0 & mydata_int$rank_emailed != 0),]$gpt_number, 
       mydata_int[(mydata_int$T_elect==0 & mydata_int$rank_facebook != 0),]$gpt_number, var.equal = FALSE)$statistic


