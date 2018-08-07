# -*- coding: utf-8 -*-

# These itmes will hold the value scraped from rottentomatoes
# critic is critic name
# movie is movie title
# org is critic organization
# rating is critic rating of movie

import scrapy

class MovieReviewItem(scrapy.Item):
    critic = scrapy.Field()
    movie = scrapy.Field()
    org = scrapy.Field()
    score = scrapy.Field()
    avg_rating = scrapy.Field()
