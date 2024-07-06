/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Structure for table `MAIN`
CREATE TABLE `MAIN` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rlsname` varchar(256) DEFAULT NULL COMMENT 'Full release name',
  `group` varchar(50) DEFAULT NULL COMMENT 'The group that released the release',
  `section` varchar(50) DEFAULT '' COMMENT 'Section name',
  `datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Release date and time',
  `lastupdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The time and date of the last modification',
  `status` set('ADDOLD', 'ADDPRE', 'SiTEPRE') DEFAULT '' COMMENT 'Status of the release',
  `files` tinyint(3) unsigned DEFAULT NULL COMMENT 'Number of files in the release',
  `size` decimal(10,3) unsigned DEFAULT NULL COMMENT 'Size of the release in MB',
  `nukereason` varchar(255) DEFAULT NULL COMMENT 'Reason for nuke',
  `genre` varchar(50) DEFAULT NULL COMMENT 'Genre of the release',
  PRIMARY KEY (`id`),
  UNIQUE KEY `rlsname_uniq` (`rlsname`),
  KEY `rls_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Structure for table `NUKE`
CREATE TABLE `NUKE` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rlsname` varchar(256) NOT NULL,
  `group` varchar(50) DEFAULT '',
  `datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `nuke` set('DELPRE', 'NUKE', 'MODDELPRE', 'MODNUKE', 'MODUNNUKE', 'UNDELPRE', 'UNNUKE') NOT NULL DEFAULT '',
  `reason` varchar(256) NOT NULL,
  `nukenet` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Structure for table `XTRA`
CREATE TABLE `XTRA` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rlsname` varchar(256) DEFAULT NULL COMMENT 'Full release name',
  `lastupdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date and time of last modification',
  `addurl` varchar(100) DEFAULT NULL COMMENT 'URL link of the release',
  `screen` varchar(256) DEFAULT NULL COMMENT 'Screenshots for the release',
  `sfv` varchar(256) DEFAULT NULL,
  `nfo` varchar(256) DEFAULT NULL,
  `m3u` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rlsname_uniq` (`rlsname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
