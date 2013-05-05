scrapeFeeds
===========

Simple threaded Ruby RSS scraper I hacked up.

* loadFeeds.rb will read an OPML exported from NetNewsWire and import it into a 'feeds' MySQL table.
* scrapeFeeds.rb will parse RSS from 'feeds' table and update 'articles' MySQL table.

Uses jruby, job queue and worker thread pool.
