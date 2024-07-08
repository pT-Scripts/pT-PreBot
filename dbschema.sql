/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table WS.MAIN
CREATE TABLE IF NOT EXISTS `MAIN` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rlsname` varchar(256) DEFAULT NULL COMMENT 'Full release name',
  `group` varchar(50) DEFAULT NULL COMMENT 'The group that released the release',
  `section` varchar(50) DEFAULT NULL COMMENT 'Section name',
  `datetime` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'release date and time',
  `lastupdated` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'The time and date of the last modification',
  `status` set('ADDOLD','ADDPRE','SiTEPRE','ADDINFO') DEFAULT '' COMMENT 'Status of the release, if it is ADDPRE or other otherwise ok',
  `files` tinyint(3) unsigned DEFAULT NULL COMMENT 'Number of files making up the release',
  `size` decimal(10,3) unsigned DEFAULT NULL COMMENT 'The size of the release expressed in MB',
  `nukereason` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `genre` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `unixtime` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rlsname_uniq` (`rlsname`) USING BTREE,
  KEY `rls_status` (`status`) USING BTREE,
  KEY `idx_group_main` (`group`),
  KEY `idx_main_id` (`id`),
  KEY `idx_main_rlsname` (`rlsname`),
  KEY `idx_main_group` (`group`),
  KEY `idx_main_section` (`section`),
  KEY `idx_main_datetime` (`datetime`),
  KEY `idx_main_lastupdated` (`lastupdated`),
  KEY `idx_main_status` (`status`),
  KEY `idx_main_files` (`files`),
  KEY `idx_main_size` (`size`),
  KEY `idx_main_nukereason` (`nukereason`),
  KEY `idx_main_genre` (`genre`),
  KEY `idx_group` (`group`),
  KEY `idx_datetime` (`datetime`),
  KEY `idx_size` (`size`),
  KEY `idx_files` (`files`),
  KEY `idx_genre` (`genre`),
  KEY `idx_id_main` (`id`),
  KEY `idx_rlsname_main` (`rlsname`),
  KEY `idx_section_main` (`section`),
  KEY `idx_datetime_main` (`datetime`),
  KEY `idx_lastupdated_main` (`lastupdated`),
  KEY `idx_status_main` (`status`),
  KEY `idx_files_main` (`files`),
  KEY `idx_size_main` (`size`),
  KEY `idx_nukereason_main` (`nukereason`),
  KEY `idx_genre_main` (`genre`),
  KEY `idx_unixtime_main` (`unixtime`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table WS.NUKE
CREATE TABLE IF NOT EXISTS `NUKE` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rlsname` varchar(256) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `group` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT '',
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  `status` set('DELPRE','NUKE','MODDELPRE','MODNUKE','MODUNNUKE','UNDELPRE','UNNUKE') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `reason` varchar(256) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `nukenet` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_group_nuke` (`group`),
  KEY `idx_nuke_id` (`id`),
  KEY `idx_nuke_rlsname` (`rlsname`),
  KEY `idx_nuke_group` (`group`),
  KEY `idx_nuke_datetime` (`datetime`),
  KEY `idx_nuke_status` (`status`),
  KEY `idx_nuke_reason` (`reason`),
  KEY `idx_nuke_nukenet` (`nukenet`),
  KEY `idx_id_nuke` (`id`),
  KEY `idx_rlsname_nuke` (`rlsname`),
  KEY `idx_datetime_nuke` (`datetime`),
  KEY `idx_status_nuke` (`status`),
  KEY `idx_reason_nuke` (`reason`),
  KEY `idx_nukenet_nuke` (`nukenet`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table WS.XTRA
CREATE TABLE IF NOT EXISTS `XTRA` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rlsname` varchar(256) DEFAULT NULL COMMENT 'Full release name',
  `lastupdated` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Date and time of last modification',
  `addurl` varchar(100) DEFAULT NULL COMMENT 'URL link of the release',
  `jpg` varchar(256) DEFAULT NULL COMMENT 'Screenshots for the release',
  `sfv` varchar(256) DEFAULT NULL,
  `nfo` varchar(256) DEFAULT NULL,
  `m3u` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `rlsname_uniq` (`rlsname`) USING BTREE,
  KEY `idx_xtra_id` (`id`),
  KEY `idx_xtra_rlsname` (`rlsname`),
  KEY `idx_xtra_lastupdated` (`lastupdated`),
  KEY `idx_xtra_addurl` (`addurl`),
  KEY `idx_xtra_jpg` (`jpg`),
  KEY `idx_xtra_sfv` (`sfv`),
  KEY `idx_xtra_nfo` (`nfo`),
  KEY `idx_xtra_m3u` (`m3u`),
  KEY `idx_id_xtra` (`id`),
  KEY `idx_rlsname_xtra` (`rlsname`),
  KEY `idx_lastupdated_xtra` (`lastupdated`),
  KEY `idx_addurl_xtra` (`addurl`),
  KEY `idx_jpg_xtra` (`jpg`),
  KEY `idx_sfv_xtra` (`sfv`),
  KEY `idx_nfo_xtra` (`nfo`),
  KEY `idx_m3u_xtra` (`m3u`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
