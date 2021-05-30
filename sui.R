#load data
suicides <- read.csv("suicidetry.csv") 

#load required packages
library(ggplot2)
library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(rworldmap)
library(countrycode)
library(rgeos)
library(data.table)
library(viridis)




suicides['groups'] = sprintf("%s.%s.%s", 
                             suicides$country,
                             suicides$sex,
                             suicides$age)
years = unique(suicides$year)
countries = unique(suicides$country)
sex = unique(suicides$sex)
ages = unique(suicides$age)

all_combinations = expand.grid(years, countries, sex, ages)
data.table::setnames(all_combinations, 
                     old = c('Var1', 'Var2', 'Var3', 'Var4'), 
                     new = c('year','country','sex','age'))

suicides_with_all_levels = left_join(all_combinations, suicides, 
                                     by = c('year','country','sex','age')) %>%
                                      arrange(country, year)


suicides_with_all_levels['groups'] = sprintf("%s.%s.%s", 
                                             suicides_with_all_levels$country,
                                             suicides_with_all_levels$sex,
                                             suicides_with_all_levels$age)

suicides_with_all_levels['estimated'] = is.na(suicides_with_all_levels$population)

grouped = suicides_with_all_levels %>%
  select('year', 'country', 'sex', 'age', 'suicides_no', 
         'population', 'suicides.100k.pop','gdp_per_capita', 'groups', 'estimated','continent') %>%
  arrange(country, year) %>%
  group_by(groups)

suicides1 = grouped %>%
  fill('population', 'suicides.100k.pop', 'suicides_no', 'gdp_per_capita','continent',
       .direction = 'up') %>%
  fill('population', 'suicides.100k.pop', 'suicides_no', 'gdp_per_capita','continent',
       .direction = 'down') %>%
  ungroup() %>%
  filter(year < 2000)

suicides2 = grouped %>%
  fill('population', 'suicides.100k.pop', 'suicides_no', 'gdp_per_capita','continent',
       .direction = 'down') %>%
  fill('population', 'suicides.100k.pop', 'suicides_no', 'gdp_per_capita','continent',
       .direction = 'up') %>%
  ungroup() %>%
  filter(year >= 2000)

suicides = rbind(suicides1, suicides2)

# there might still be countries, where our estimation failed
countries_with_na = unique(suicides[is.na(suicides$population),]$country)
suicides = suicides %>% filter(!country %in% countries_with_na)



suicides['year_and_country'] = sprintf("%s.%s", suicides$country, suicides$year)

suicides_by_country = suicides %>%
  group_by(year_and_country) %>%
  summarise(
    year = head(year, 1),
    country = head(country, 1),
    estimated = head(estimated, 1),
    population = sum(population),
    suicides_no = sum(suicides_no),
    suicides_per_100k = sum(population * suicides.100k.pop) / (as.numeric(sum(population)) * n()),
    gdp_per_capita = mean(gdp_per_capita),
    continent = head(continent, 1))

suicides_by_country['country_code'] = countrycode(suicides_by_country$country, 'country.name','iso2c' )



               
               