-- Create syntax for TABLE 'articles'
CREATE TABLE `articles` (
  `pkArticleId` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `fkFeedId` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `date` varchar(255) DEFAULT NULL,
  `description` text,
  `content` text,
  `published` varchar(255) DEFAULT NULL,
  `firstSeen` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`pkArticleId`)
) ENGINE=InnoDB AUTO_INCREMENT=2539 DEFAULT CHARSET=latin1;

-- Create syntax for TABLE 'feeds'
CREATE TABLE `feeds` (
  `pkFeedId` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `url` varchar(500) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`pkFeedId`)
) ENGINE=InnoDB AUTO_INCREMENT=154 DEFAULT CHARSET=latin1;