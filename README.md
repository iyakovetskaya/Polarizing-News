# Polarizing-News
Data and Code for H. Yoganarasimhan and I. Yakovetskaya. Is Social Media Seeded with Polarizing News?

## Data

1. Most_popular_id_2019_2021.csv 

Contains data on rankings of top-20 most emailed and most shared on Facebook articles parsed from https://www.nytimes.com/trending/ using Internet Archive.
- Date
- Rank - from 1 to 20 for each date
- id_emailed - our project-specific id for an article with a given rank on a given date (Emailed)
- id_facebook - our project-specific id for an article with a given rank on a given date (Facebook)

2. articles_data.csv

Contains data for articles used in the project (except full text)
- id - our project-specific id for the article
- link - URL of a given article
- headline_main - headline of a given article
- abstract, snippet, lead_paragraph, print_section, print_page, source, pub_date, document_type, news_desk, section_name, type_of_material, word_count,uri,byline_original,byline_organization - metadata obtained using NYTimes API (more: https://developer.nytimes.com/docs/articlesearch-product/1/overview)
- nyt_id - ID specific for NYTimes
- has_full_text - out indicator of whether we were able to obtain the full text for a given article (only these article are used in LDA)

3. panel_polarization_full.csv

Contains results from LDA and other metadata used for regressions. Has a panel structure with date, article
- date_id - our project-specific id for a date (for which we have ranking data)
- id - our project-specific id for the article (rows only for articles that are ranked at least on one list on a given date)
- rank_emailed - rank of a given article on a given day in the most emailed list 
- rank_facebook - rank of a given article on a given day in the most shared on Facebook list 
- actual_date - a date that corresponds to date_id


...article-specific controls - metadata from articles_data.csv (or its derivatives such as the length of the headline)...

- topic_i (for i=1,2, ...40) - proportion of topic i in a given article
- t_after_release - time after release of a given article on a given date
- gpt_number - polarization score obtained through GPT3.5

4. Model files (LDA_final_40_topics, .expElogbeta.npy, .id2word and .state)

Files specific to the Gensim package in Python. Save files for the model used in the paper, can be uploaded in Code/2_LDA.ipynb.

5. Model/LDA_final_40_topics_summary_table.csv

Contains summary statistics for topics resulting from LDA.

- Topic_num - 40 topics in total
- Relevance - prevalence of a given topic in the whole corpus 
- Keywords - 10 words with the highest probabilities in a given topic
- Topic_Perc_Contrib - the highest proportion of a given topic in an article (in our corpus)
- Text - text of the article with the highest proportion of a given topic

6. LDA_final_topic_names.csv 

Contains names (short for figures and long for tables) for each LDA topic.

7.  summary_for081823_names.csv

8. survey_results.csv

## Code

All code files are presented in the order of a paper structure.

1_Data_Description.ipynb

- Provides description of articles data and rankings and initial analysis of differences. 
- Code for for Appendix A: Table A1, Figures A1-3
- Uses Most_popular_id_2019_2021.csv and articles_data.csv

2_Survey results.ipynb

3_GPT.ipynb

4_Topic_level_polarization.ipynb

5_Regressions.R

- Runs all regressions
- Creates Tables A3, A4 and saves regression estimates for further visualization
- Uses panel.csv

## Code that requires full text for articles 

A1_grid_search_for_LDA.ipynb

A2_LDA.ipynb

- Cleans data, runs LDA model, and provides visualization and description of LDA results.
- Creates Tables 2, 3, A2, and Figures 2, A6
- Uses Most_popular_id_2019_2021.csv and articles_data.csv but requires full text if you intend to run a model
- Final model also could be uploaded using gensim package-specific files in /Data/Model/

A3_GPT_individual_articles-final.ipynb

