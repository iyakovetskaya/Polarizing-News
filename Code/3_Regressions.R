library(fixest);library(dplyr)

mydata <- read.csv('../Data/panel.csv')

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

#Create categories:
mydata$t_num<-mydata$t_after_release
mydata$date_num<-mydata$date_id
cats <- c("date_id","t_after_release", "print_section", "section_name", "news_desk") #Indicators for other covariates
mydata[ ,cats] <- lapply(mydata[ ,cats], as.factor)


###Main Regressions - Table A3###

#Difference in ranks

topics <- paste("topic", 1:39, sep="_")

fla<-as.formula(paste("rankef_diff25 ~ ", "t_num  +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print +", 
                      paste(topics, collapse= "+"))) 

reg1 <- feols( fml = fla, data = mydata, cluster ='date_id') ##vcov="HC1",

#Binary dependent variable
fla2<-as.formula(paste("egreater ~ ", "t_num +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print + ", 
                       paste(topics, collapse= "+"))) 

reg2 <- feols(fml = fla2, data = mydata, cluster ='date_id',
)

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

#Export table:

etable(reg1, reg2, drop=c("section_name", "print_section", "date_id[[:digit:]]"), title="Regressions", label="Regressions",
       extralines=list("-Section_name"=c("Yes", "Yes"),
                       "_Sub-sample"=c("All", "Both ranked", "All")),
       order=c('%topic_29', '%topic_22', '%topic_7', '%topic_16', '%topic_12', 
               '%topic_2', '%topic_37', '%topic_14', '%topic_8', '%topic_35', 
               '%topic_23', '%topic_11', '%topic_20', '%topic_33', '%topic_6', 
               '%topic_5', '%topic_31', '%topic_15', '%topic_38', '%topic_28', 
               '%topic_40', '%topic_26', '%topic_10', '%topic_4', '%topic_3', 
               '%topic_27', '%topic_19', '%topic_36', '%topic_25', '%topic_13', 
               '%topic_24', '%topic_18', '%topic_39', '%topic_9', '%topic_32', 
               '%topic_1', '%topic_30', '%topic_34', '%topic_17', '%topic_21', 
               "word_count", "headline_main_len", "snippet_len", "polarity_full_text" ,"print"),
       dict=topic_names, digits='r3', family=TRUE, tex=TRUE, se.below=FALSE) #

#Export coefficients for Figure 3
s<-summary(reg1)$coefficients
write.csv(s,file="../Data/reg_1_coef.csv")

###Validity checks - Table A4###

#Difference in ranks with unranked=30 and 35

fla30<-as.formula(paste("rankef_diff30 ~ ", "t_num  +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print +", 
                      paste(topics, collapse= "+"))) 
fla35<-as.formula(paste("rankef_diff35 ~ ", "t_num  +t_num^2+ word_count +  headline_main_len +  
                      snippet_len + section_name + print +", 
                      paste(topics, collapse= "+"))) 

reg30 <- feols( fml = fla30, data = mydata, cluster ='date_id')
reg35 <- feols( fml = fla35, data = mydata, cluster ='date_id')

#Export table:
  
etable(reg30, reg35, drop=c("section_name", "print_section", "t[[:digit:]]", "date_id[[:digit:]]"), title="Regressions", label="Regressions",
       extralines=list("-Section_name"=c("Yes", "Yes", "Yes"),
                       "-Days after release"=c("","" , "Yes"),
                       "_Sub-sample"=c("All_ranked", "All_ranked", "first_14_days")),
       order=c('%topic_29', '%topic_22', '%topic_7', '%topic_16', '%topic_12', 
               '%topic_2', '%topic_37', '%topic_14', '%topic_8', '%topic_35', 
               '%topic_23', '%topic_11', '%topic_20', '%topic_33', '%topic_6', 
               '%topic_5', '%topic_31', '%topic_15', '%topic_38', '%topic_28', 
               '%topic_40', '%topic_26', '%topic_10', '%topic_4', '%topic_3', 
               '%topic_27', '%topic_19', '%topic_36', '%topic_25', '%topic_13', 
               '%topic_24', '%topic_18', '%topic_39', '%topic_9', '%topic_32', 
               '%topic_1', '%topic_30', '%topic_34', '%topic_17', '%topic_21', 
               "word_count", "headline_main_len", "snippet_len", "polarity_full_text" ,"print"),
       dict=topic_names, digits='r3', family=TRUE, tex=TRUE, se.below=FALSE) #

###Change over time###

#Divide into 2 subsets:

mydata<-mydata %>%
  mutate(
    T_2020 = case_when(
    actual_date>='2020-12-01' ~ 1,
    actual_date<'2020-11-01' ~ 0,
    TRUE ~ 2 #exclude November
  ))

#Exclude November (elections)
mydata<-mydata[!mydata$T_2020==2,]

mydata<-mydata[mydata$actual_date>="2020-01-01",] #equal subsamples

#2 regressions

reg_pre2020 <- feols( fml = fla, data = mydata, cluster ='date_id', subset=mydata$T_2020==0)
reg_post2020 <- feols( fml = fla, data = mydata, cluster ='date_id', subset=mydata$T_2020==1)

#Export table

etable(reg_pre2020,reg_post2020, drop=c("section_name", "print_section", "t[[:digit:]]", "date_id[[:digit:]]"), title="Regressions", label="Regressions",
       order=c('%topic_29', '%topic_22', '%topic_7', '%topic_16', '%topic_12', 
               '%topic_2', '%topic_37', '%topic_14', '%topic_8', '%topic_35', 
               '%topic_23', '%topic_11', '%topic_20', '%topic_33', '%topic_6', 
               '%topic_5', '%topic_31', '%topic_15', '%topic_38', '%topic_28', 
               '%topic_40', '%topic_26', '%topic_10', '%topic_4', '%topic_3', 
               '%topic_27', '%topic_19', '%topic_36', '%topic_25', '%topic_13', 
               '%topic_24', '%topic_18', '%topic_39', '%topic_9', '%topic_32', 
               '%topic_1', '%topic_30', '%topic_34', '%topic_17', '%topic_21', 
               "word_count", "headline_main_len", "snippet_len", "polarity_full_text" ,"print"),
       dict=topic_names, digits='r3', family=TRUE, tex=TRUE)

#Export coefficients:

res_before<-summary(reg_pre2020)$coefficients
write.csv(res_before,file="../Data/sep_reg_before_coef.csv")

res_after<-summary(reg_post2020)$coefficients
write.csv(res_after,file="../Data/sep_reg_after_coef.csv")

