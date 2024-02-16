# Polarizing-News
Data and Code for H. Yoganarasimhan and I. Iakovetskaia. From Feeds to Inboxes: A Comparative Study of Polarization in
Facebook and Email News Sharing

## Data

1. Most_popular_id_2019_2021.csv 

Contains data on rankings of the top-20 most emailed and most shared on Facebook articles parsed from https://www.nytimes.com/trending/ using Internet Archive.
- Date
- Rank - from 1 to 20 for each date (1 is the highest in the list, 20 is the lowest)
- id_emailed - our project-specific id for an article with a given rank on a given date (Emailed)
- id_facebook - our project-specific id for an article with a given rank on a given date (Facebook)

2. articles_data.csv

Contains data for articles used in the project (except full text)
- id - our project-specific ID for the article
- link - URL of a given article
- headline_main - headline of a given article
- abstract, snippet, lead_paragraph, print_section, print_page, source, pub_date, document_type, news_desk, section_name, type_of_material, word_count,uri,byline_original,byline_organization - metadata obtained using NYTimes API (more: https://developer.nytimes.com/docs/articlesearch-product/1/overview)
- nyt_id - ID specific for NYTimes
- has_full_text - out indicator of whether we were able to obtain the full text for a given article (only these articles are used in LDA)

3. panel_polarization_full.csv

Contains results from LDA and other metadata used for regressions. Has a panel structure with date, article
- date_id - our project-specific id for a date (for which we have ranking data)
- id - our project-specific ID for the article (rows only for articles that are ranked at least on one list on a given date)
- rank_emailed - rank of a given article on a given day in the most emailed list 
- rank_facebook - rank of a given article on a given day in the most shared on Facebook list 
- actual_date - a date that corresponds to date_id

...article-specific controls - metadata from articles_data.csv (or its derivatives such as the headline length)...

- topic_i (for i=1,2, ...40) - the proportion of topic i in a given article
- t_after_release - time after release of a given article on a given date
- gpt_number - polarization score obtained through GPT3.5

4. Model files (LDA_final_40_topics, .expElogbeta.npy, .id2word and .state)

Files specific to the Gensim package in Python. Save files for the model used in the paper, which can be uploaded to Code/A2_LDA.ipynb.

5. Model/LDA_final_40_topics_summary_table.csv

Contains summary statistics for topics resulting from LDA.

- Topic_num - 40 topics in total
- Relevance - prevalence of a given topic in the whole corpus 
- Keywords - 10 words with the highest probabilities in a given topic
- Topic_Perc_Contrib - the highest proportion of a given topic in an article (in our corpus)
- Text - text of the article with the highest proportion of a given topic

6. LDA_final_topic_names.csv 

Contains names used in the article (short for figures and long for tables) for each LDA topic.

7.  summary_for081823_names.csv

Contains summary results for GPT polarization score for each topic 
- id is a topic name
- survey - average polarization score for the topic obtained from the survey 
- gpt_topics_avg - average polarization score for the topic obtained from GPT using topic names 
- gpt_keywords_avg- average polarization score for the topic obtained from GPT using keywords for topics 
All polarization scores are standardized across respondents (or multiple calls of GPT)

9. survey_results.csv

Contains selected columns for the survey results; all identifiers were removed
- Progress - the percentage of the survey filled by the participant
- ResponseId - identifier of the response
- Polarization_i (for i=1,2, ...40) - ranked polarization of an article i on a scale from 1 to 5
- Personal1-8 - answers to questions about demographics
- Personal_4_i (for i=1,2, ...40) - how important it is that your social circle knows about your opinions on a topic i

10. summary_results.csv

Equivalent of Table A5 

## Code

All code files are presented in the order of a paper structure.

1_Data_Description.ipynb

- Provides description of article data and rankings and initial analysis of differences.
- Code for for Appendix A: Table A1, Figures A1-3
- Uses Most_popular_id_2019_2021.csv and articles_data.csv

2_Survey results.ipynb

- Provides analysis of survey results
- Code for Table A5 and values from the survey used in the paper text
- Generates summary_results.csv, which is table A5

3_GPT.ipynb

- Code that was used to generate polarization scores on the topic level (using topic name and keywords)
- Requires GPT API key to run
- Does not generate any table for the paper but generates summary_for081823_names.csv file used in 4_Topic_level_polarization.ipynb
- Polarization scores on an article level are generated by A3_GPT_individual_articles-final.ipynb but require data in the full article text to run

4_Topic_level_polarization.ipynb

- Generates Table 2 and Table 3 in the main text
- Uses summary_for081823_names.csv - summary of results from GPT generated by 3_GPT.ipynb and A3_GPT_individual_articles-final.ipynb 

5_Regressions.R

- Code for all regressions used in the paper
- Creates Tables 4, 5, A6, and A7
- Uses panel_polarization_full.csv

### Code that requires full text for articles 

All code files here require data on the full article text to run, which we do not provide since it's behind the paywall. We provide article URLs and NYTimes unique IDs (used in their API) in the articles_data.csv, so it should be possible to locate each article and obtain article text.

A1_grid_search_for_LDA.ipynb

- Cleans data, runs multiple LDA models, and computes their coherence scores to find optimal parameters
- Contains code to generate Figure A4, generates figure A5

A2_LDA.ipynb

- Cleans data, runs LDA model and provides visualization and description of LDA results.
- Creates Tables 1, A3 and Figures 2, A6
- Uses Most_popular_id_2019_2021.csv and articles_data.csv but requires full text if you intend to run a model
- The final model also could be uploaded using gensim package-specific files in /Data/Model/

A3_GPT_individual_articles-final.ipynb

- Similar to 3_GPT.ipynb but cycles through each article to generate a polarization score on an article level instead of a topic level


## Version control

### Python
- python version 3.9.13
- pandas2.0.0
- numpy1.26.4
- seaborn0.13.2
- matplotlib3.5.2
- openai0.27.8
- re2.2.1
- json2.0.9
- gensim4.1.2
- spacy3.7.2
- - spacy download en_core_web_sm
- pyLDAvis3.4.0
- nltk3.7
- - nltk.download('stopwords')

### R

- R version 4.3.2 (2023-10-31)
- xtable_1.8-4
- kableExtra_1.4.0
- dplyr_1.1.4
- fixest_0.11.2
