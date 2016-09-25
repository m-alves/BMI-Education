library(tidyverse)
library(data.table)
library(stringr)

#reading data
bmi <- fread('hlth_ehis_de1.tsv', sep = '\t', stringsAsFactors = F)
head(bmi)

#Separate united columns and gathering variable edu_level.
bmi <- separate(bmi, 'time,bmi,sex,age,geo\\isced97', c('year', 'bmi', 'sex', 'age', 'country'), sep = ',', )
names(bmi)[names(bmi) == 'ED0-2'] <- 'ED0_2'
bmi <- gather(bmi, 'edu_level', 'percentage', c(TOTAL, ED0_2, ED3_4, ED5_6))

#Replacing the category of several variables to more understandable terms

bmi$bmi <- str_replace(bmi$bmi,'18P5-25','Normal')
bmi$bmi <- str_replace(bmi$bmi,'LT18P5','Underweight')
bmi$bmi <- str_replace(bmi$bmi,'25-30','Overweight')
bmi$bmi <- str_replace(bmi$bmi,'GE30','Obese')
bmi$sex <- str_replace(bmi$sex, 'F', 'Female')
bmi$sex <- str_replace(bmi$sex, 'M', 'Male')
bmi$sex <- str_replace(bmi$sex, 'T', 'Total')

#Factorizing some variables
bmi$sex <- as.factor(bmi$sex)

#Ordering some factors
bmi$bmi <- factor(bmi$bmi, levels = c('Underweight', 'Normal', 'Overweight', 'Obese'))
bmi$age <- factor(bmi$age, levels = c('Y18-24','Y25-34', "Y35-44", "Y45-54", "Y55-64", "Y65-74", 'Y75-84', 'Y_GE85', 'TOTAL'))
bmi$edu_level <- factor(bmi$edu_level, levels = c('ED0_2', 'ED3_4', 'ED5_6', 'TOTAL'))

#Eliminate 'c' and 'u' from records
bmi$percentage <- gsub(pattern = 'u|c', replacement = '', x = bmi$percentage)

#Convert percentage column to numeric class
bmi$percentage <- as.numeric(bmi$percentage)

#Remove NA's
bmi <- drop_na(bmi)

#Grouping by age, after removing country column, so we can analize in genera perspective. 
# The table with the country column will allow to analyze for each individual country if needed
bmi_tot_age <- bmi %>%
 select(bmi:age,edu_level:percentage)
 group_by(age, bmi, edu_level, sex)  %>%
 summarise(percentage_tot = mean(percentage)) %>%
 arrange(age)
 
#ggplot(bmi_tot_age, aes(x = age, y = percentage_tot, col = edu_level)) + geom_point()






