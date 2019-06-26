

#'--- 
#' title: "PRGH ED visits by day of week"
#' author: "Nayef Ahmad"
#' date: "2019-06-24"
#' output: 
#'   html_document: 
#'     keep_md: yes
#'     code_folding: hide
#'     toc: true
#'     toc_float: true
#' ---

#+ libraries, message = FALSE 
library(here)
library(tidyverse)
library(DT)
library(ggbeeswarm)
library(broom)

# 1) read data -------------

df1.ed_visits <- read_csv(here::here("2019-06-25_prgh_mh-visits-by-day-of-week.csv"))


str(df1.ed_visits)


df2.ed_visits_clean <- 
  df1.ed_visits %>% 
  mutate(weekday = factor(DayOfWeek, 
                          levels = c("Monday", 
                                     "Tuesday", 
                                     "Wednesday", 
                                     "Thursday", 
                                     "Friday",
                                     "Saturday", 
                                     "Sunday")))

# str(df2.ed_visits_clean)

df2.ed_visits_clean %>% datatable()



# 2) plots --------
df2.ed_visits_clean %>% 
  pull(ed_visits) %>% 
  hist


df2.ed_visits_clean %>% 
  pull(ed_visits_known_to_PARIS_MH) %>% 
  hist


#'
#'  ## ED visits 
#'

df2.ed_visits_clean %>% 
  ggplot(aes(x = weekday, 
             y = ed_visits)) + 
  
  geom_boxplot() + 
  theme_light() +
  theme(panel.grid.minor = element_line(colour = "grey95"), 
        panel.grid.major = element_line(colour = "grey95"))


df2.ed_visits_clean %>% 
  ggplot(aes(x = weekday, 
             y = ed_visits)) + 
  
  geom_beeswarm() + 
  theme_light() +
  theme(panel.grid.minor = element_line(colour = "grey95"), 
      panel.grid.major = element_line(colour = "grey95"))
      



#'
#'  ## ED visits known to PARIS MH 
#'

df2.ed_visits_clean %>% 
  ggplot(aes(x = weekday, 
             y = ed_visits_known_to_PARIS_MH)) + 
  
  geom_boxplot() + 
  theme_light() +
  theme(panel.grid.minor = element_line(colour = "grey95"), 
        panel.grid.major = element_line(colour = "grey95"))


df2.ed_visits_clean %>% 
  ggplot(aes(x = weekday, 
             y = ed_visits_known_to_PARIS_MH)) + 
  
  geom_beeswarm() + 
  theme_light() +
  theme(panel.grid.minor = element_line(colour = "grey95"), 
        panel.grid.major = element_line(colour = "grey95"))



# 3) regression ------------



m1.mh_ed_visits <- lm(ed_visits_known_to_PARIS_MH ~ weekday, 
                      data = df2.ed_visits_clean)

summary(m1.mh_ed_visits)

par(mfrow = c(2,2))
plot(m1.mh_ed_visits)
par(mfrow = c(1,1))

df3.mh_coeffs <- 
  tidy(m1.mh_ed_visits) %>% 
  mutate(lower = estimate - 1.96 * std.error, 
         upper = estimate + 1.96 * std.error)


#'
#' ## Notes
#'  

#'  Model not significant. We cannot conclude that there is any weekday effect -
#'  too much variability, not enough data
#'  


m2.all_ed_visits <- lm(ed_visits ~ weekday, 
                       data = df2.ed_visits_clean)

summary(m2.all_ed_visits)

par(mfrow = c(2,2))
plot(m2.all_ed_visits)
par(mfrow = c(1,1))


df4.coeffs <- 
  tidy(m2.all_ed_visits) %>% 
  mutate(lower = estimate - 1.96 * std.error, 
         upper = estimate + 1.96 * std.error)


#'
#' ## Notes
#'

#'  In this case, there are significant weekday effects 
#'  



# 4) visualize effects: 

df4.coeffs %>% 
  filter(grepl("weekday", term)) %>% 
  
  mutate(term = substring(term, 8)) %>% 
  mutate(term = factor(term, 
                       levels = c("Monday", 
                                  "Tuesday", 
                                  "Wednesday", 
                                  "Thursday", 
                                  "Friday",
                                  "Saturday", 
                                  "Sunday"))) %>%
  
  ggplot()  +
  geom_pointrange(aes(x = term, 
                      ymin = lower, 
                      ymax = upper, 
                      y = estimate)) + 
  geom_hline(yintercept = 0) + 
  
  scale_y_continuous(limits = c(-10, 10), 
                     breaks = seq(-10, 10, 4)) + 
  
  labs(x = "Day of week", 
       y = "Difference in average daily ED visits" ,
       title = "PRGH ED \nImpact of Day of Week on average daily ED visits", 
       subtitle = "\nBaseline - Monday") + 
  
  
  theme_light() +
  theme(panel.grid.minor = element_line(colour = "grey95"), 
      panel.grid.major = element_line(colour = "grey95"))
      

