---
title: Contact
---
<center>
Division of Psychiatry<br/>
University College London<br/>  
6th Floor, Maple House<br/>
149 Tottenham Court Road<br/>
London W1T 7NF<br/>

<justin.yang@ucl.ac.uk>  
[@JustinCYang](https://twitter.com/JustinCYang)
</center>


```{r}
library(scholar)
library(tidyverse)
library(glue)

# Run this code, then put the outputs in publications.html into publications.md. 
# Delete publications.html afterwards.

html_2 <-  get_publications("o-MsbBYAAAAJ") %>%
  as_tibble %>% arrange(desc(year)) %>%
  mutate(
    #    author=str_replace_all(author, " (\\S) ", "\\1 "),
    author=str_replace_all(author, "([A-Z]) ([A-Z]) ", "\\1\\2 "),
    author=str_replace_all(author, ", \\.\\.\\.", " et al."),
    author=str_replace_all(author, "JC Yang", "<b>JC Yang</b>"), # make my name fat
    author=str_replace_all(author, "J Yang", "<b>J Yang</b>") # make my name fat
  ) %>% split(.$year) %>%
  map(function(x){
    x <- x %>%
      glue_data('<tr><td width="100%">{author} ({year}) <a href="https://scholar.google.com/scholar?oi=bibs&cluster={cid}&btnI=1&hl=en">{title}</a>, {journal}, {number}</td></tr>') %>%
      str_replace_all("(, )+</p>", "</p>") %>%
      char2html()
    x <- c('<table><tbody>', x, '</tbody></table>')
    return(x);
  }) %>% rev

html_3 <- map2(names(html_2) %>% paste0("<h3>", ., "</h3>"), html_2, c) %>% unlist
```