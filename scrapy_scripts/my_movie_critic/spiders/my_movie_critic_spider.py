from scrapy import Spider, Request
from my_movie_critic.items import MovieReviewItem
import re

class MovieReviewSpider(Spider):
    name = 'movie_review_spider'
    allowed_urls = ['https://www.rottentomatoes.com']
    # urls for top 100 movies from 2000 to 2018
    start_urls = ['https://www.rottentomatoes.com/top/bestofrt/?year=' + str(x) for x in range(2000, 2019)]

    def parse(self, response):
        # This function parses the Top 100 movies of 20XX pages

        # Find the movie table and find the movie title and review count for each movie
        movie_table = response.xpath('//table[@class="table"]/tr')
        movie_links = movie_table.xpath('./td/a/@href').extract()
        review_count = movie_table.xpath('./td[@class="right hidden-xs"]/text()').extract()

        # Yield the requests to different movie pages where review count is greater than or equal to 100,
        # using parse_movie_page function to parse the response
        for url, count in zip(movie_links, review_count):
            # only yeild if review count is greater than or equal to 100
            if (int(count) >= 100):
                # re.sub() to replace hyphens with underscores, hyphens produced redirect code 301
                yield Request(url = ('https://www.rottentomatoes.com' + re.sub('-', '_', url)), callback = self.parse_movie_page)

    def parse_movie_page(self, response):
        # This function parses the individual movies from the Top 100 of 20XX pages

        # Find the url to All Critics page
        review_url = response.xpath('//p[@id="criticHeaders"]/a/@href').extract()[0]
        avg_rating = response.xpath('//div[@id="scoreStats"]/div/text()').extract()[1].strip()

        yield Request(url = ('https://www.rottentomatoes.com' + review_url), meta = {'avg_rating': avg_rating}, callback = self.parse_review_page)

    def parse_review_page(self, response):
        # This function parses each page of the All Critics section of a movie

        # Find the list of critics and their organization and score
        reviews = response.xpath('//div[@class="row review_table_row"]')
        # Find movie title
        movie = response.xpath('//div[@class="panel-body content_body"]//h2/a/text()').extract_first()
        avg_rating = response.meta['avg_rating']

        for review in reviews:
            critic = review.xpath('.//div[@class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"]/a/text()').extract_first()
            org = review.xpath('.//div[@class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"]/a/em/text()').extract_first()
            score = review.xpath('.//div[@class="review_desc"]/div[@class="small subtle"]/text()').extract()

            # If this critic does not give a score, skip
            if score in [[' ', ' '], [' '], [' Full Review']]:
                continue
            # If critic name is not supplied, use org name instead
            if critic == ' ':
                critic = org

            # Removes unnecessary text from score and elements from score
            if len(score) == 1:
                score = re.sub('.*Original Score: ', '', score[0])
            else:
                score = re.sub('.*Original Score: ', '', score[1])

            item = MovieReviewItem()
            item['critic'] = critic
            item['movie'] = movie
            item['org'] = org
            item['score'] = score
            item['avg_rating'] = avg_rating

            yield item

        # Find the total number of pages for review page
        num_pages = re.sub('Page 1 of ', '', response.xpath('//div[@class="panel-body content_body"]//span[@class="pageInfo"]/text()').extract_first())
        following_urls = [response.url + '?page={}&sort='.format(x) for x in range(2, int(num_pages) + 1)]

        # Follow the remaining review page urls
        for url in following_urls:
            yield Request(url = url, meta = {'movie': movie, 'avg_rating': avg_rating}, callback = self.parse_following_review_page)

    def parse_following_review_page(self, response):
        # This function parses the remaining review pages

        # Find the list of critics and their organization and score
        reviews = response.xpath('//div[@class="row review_table_row"]')
        # Retrieve movie title as meta data
        movie = response.meta['movie']
        avg_rating = response.meta['avg_rating']

        for review in reviews:
            critic = review.xpath('.//div[@class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"]/a/text()').extract_first()
            org = review.xpath('.//div[@class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"]/a/em/text()').extract_first()
            score = review.xpath('.//div[@class="review_desc"]/div[@class="small subtle"]/text()').extract()

            # If this critic does not give a score, skip
            if score in [[' ', ' '], [' '], [' Full Review']]:
                continue
            # If critic name is not supplied, use org name instead
            if critic == ' ':
                critic = org

            # Removes unnecessary text from score and elements from score
            if len(score) == 1:
                score = re.sub('.*Original Score: ', '', score[0])
            else:
                score = re.sub('.*Original Score: ', '', score[1])

            item = MovieReviewItem()
            item['critic'] = critic
            item['movie'] = movie
            item['org'] = org
            item['score'] = score
            item['avg_rating'] = avg_rating

            yield item
