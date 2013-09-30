use todo;

CREATE TABLE `sample` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id1` int(11) unsigned NOT NULL,
  `id2` int(11) unsigned NOT NULL,
  `id3` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id1` (`id1`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `user` (
  `uid` int(11) unsigned NOT NULL,
  `screen_name` varchar(20) NOT NULL,
  `updated_at` int(11) unsigned NOT NULL,
  `created_at` int(11) unsigned NOT NULL,
  PRIMARY KEY (`uid`),
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `todo` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `title` varchar(100) NOT NULL,
  `priority` int(11) unsigned NOT NULL,
  `due` int(11) unsigned NOT NULL,
  `updated_at` int(11) unsigned NOT NULL,
  `created_at` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

