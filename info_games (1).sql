-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 30, 2026 at 02:09 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `info_games`
--

-- --------------------------------------------------------

--
-- Table structure for table `metacritic_games`
--

CREATE TABLE `metacritic_games` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `release_date` varchar(100) DEFAULT NULL,
  `metascore` varchar(10) DEFAULT NULL,
  `user_score` varchar(10) DEFAULT NULL,
  `genre` varchar(255) DEFAULT NULL,
  `url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `image_url` text DEFAULT NULL,
  `source` varchar(255) NOT NULL,
  `User_review` varchar(255) NOT NULL,
  `User_Review_Percent` int(11) DEFAULT NULL,
  `last_scraped` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `metacritic_games`
--

INSERT INTO `metacritic_games` (`id`, `title`, `release_date`, `metascore`, `user_score`, `genre`, `url`, `created_at`, `image_url`, `source`, `User_review`, `User_Review_Percent`, `last_scraped`) VALUES
(1587, 'Clair Obscur: Expedition 33', 'Apr 24, 2025', '93', '93', 'JRPG', 'https://www.metacritic.com/game/clair-obscur-expedition-33/', '2025-10-03 06:11:10', 'https://cdn1.epicgames.com/spt-assets/330dace5ffc74156987f91d454ac544b/project-w-1kt2x.jpg', '', '99%', NULL, ''),
(1588, 'Baldur\'s Gate 3', 'Aug 3, 2023', '96', '96', 'Western RPG', 'https://www.metacritic.com/game/baldurs-gate-3/', '2025-10-03 06:11:13', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1086940/48a2fcbda8565bb45025e98fd8ebde8a7203f6a0/header.jpg?t=1748346026', '', '99%', NULL, ''),
(1589, 'Half-Life: Alyx', 'Mar 23, 2020', '93', '93', 'FPS', 'https://www.metacritic.com/game/half-life-alyx/', '2025-10-03 06:11:16', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQF9oP6yLZgfEf1TF8sGyO_kIKMKfJco3djuA&s', '', '97%', NULL, ''),
(1590, 'Sonic x Shadow Generations', 'Oct 25, 2024', '80', '80', '3D Platformer', 'https://www.metacritic.com/game/sonic-x-shadow-generations/', '2025-10-03 06:11:19', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEdEZUJuc8y7dHAPop6ZO5E7dl6TycUaapuw&s', '', '86%', NULL, ''),
(1591, 'Omori', 'Dec 25, 2020', '87', '87', 'RPG', 'https://www.metacritic.com/game/omori/', '2025-10-03 06:11:22', 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1150690/capsule_616x353.jpg?t=1671584768', '', '100%', NULL, ''),
(1592, 'The Great Ace Attorney Chronicles', 'Jul 27, 2021', '86', '86', 'Compilation', 'https://www.metacritic.com/game/the-great-ace-attorney-chronicles/', '2025-10-03 06:11:25', 'https://www.nintendo.com/eu/media/images/10_share_images/games_15/nintendo_switch_download_software_1/H2x1_NSwitchDS_TheGreatAceAttorneyChronicles_image1600w.jpg', '', '98%', NULL, ''),
(1593, 'Final Fantasy XIV: Endwalker', 'Dec 7, 2021', '92', '92', 'MMORPG', 'https://www.metacritic.com/game/final-fantasy-xiv-endwalker/', '2025-10-03 06:11:28', 'https://img.online-station.net/image_content/2021/12/final04-1.jpg', '', '100%', NULL, ''),
(1594, 'drowning (Rapture)', 'Feb 16, 2022', 'tbd', 'tbd', 'First-Person Adventure', 'https://www.metacritic.com/game/drowning-rapture/', '2025-10-03 06:11:31', 'https://i.ytimg.com/vi/d65f1zPnbbY/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLDBbaQY1w3Q5s0lmG9pxs2e6l7KDw', '', '88%', NULL, ''),
(1595, 'Split Fiction', 'Mar 6, 2025', '91', '91', 'Linear Action Adventure', 'https://www.metacritic.com/game/split-fiction/', '2025-10-03 06:11:33', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2001120/5a3209f496e911ff2fa6dccd58c682c89632d09b/capsule_616x353.jpg?t=1748910778', '', '96%', NULL, ''),
(1596, 'Stellar Blade', 'Jun 11, 2025', '81', '81', 'Action Adventure', 'https://www.metacritic.com/game/stellar-blade/', '2025-10-03 06:11:36', 'https://i.ytimg.com/vi/Pex7jW3Tqwo/maxresdefault.jpg', '', '84%', NULL, ''),
(1597, 'Hollow Knight: Silksong', 'Sep 4, 2025', '91', '91', 'Metroidvania', 'https://www.metacritic.com/game/hollow-knight-silksong/', '2025-10-03 06:11:37', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSb0HrAaWxeVCT1cftwikJ5RC51FXdN4anrw5J4Y4QM1X80LtTpxJGN_FiwthtQ08AstQ&usqp=CAU', '', '94%', NULL, ''),
(1598, 'Factorio', 'Aug 14, 2020', '90', '90', 'Tycoon', 'https://www.metacritic.com/game/factorio/', '2025-10-03 06:11:40', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/427520/header.jpg', '', '100%', NULL, ''),
(1599, 'Systematic Insanity', 'Mar 28, 2021', 'tbd', 'tbd', 'Visual Novel', 'https://www.metacritic.com/game/systematic-insanity/', '2025-10-03 06:11:43', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwBvHtbf7OcGxNHSEHxPGz-a1xK7XS2GJArw&s', '', '86%', NULL, ''),
(1600, 'Pizza Tower', 'Jan 26, 2023', '89', '89', '2D Platformer', 'https://www.metacritic.com/game/pizza-tower/', '2025-10-03 06:11:46', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2231450/header.jpg?t=1732516978', '', '100%', NULL, ''),
(1601, 'Cruelty Squad', 'Jun 15, 2021', '89', '89', 'FPS', 'https://www.metacritic.com/game/cruelty-squad/', '2025-10-03 06:11:49', 'https://upload.wikimedia.org/wikipedia/en/3/31/Cruelty_Squad_Steam_Header.jpg', '', '100%', NULL, ''),
(1602, 'Digimon Survive', 'Jul 29, 2022', '70', '70', 'Turn-Based Tactics', 'https://www.metacritic.com/game/digimon-survive/', '2025-10-03 06:11:51', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHoc4hYX7qM8WwdItBBHWPpA3ikp1sUbiUGQ&s', '', '43%', NULL, ''),
(1603, 'Outer Wilds: Echoes of the Eye', 'Sep 28, 2021', '82', '82', 'Open-World Action', 'https://www.metacritic.com/game/outer-wilds-echoes-of-the-eye/', '2025-10-03 06:11:54', 'https://img-eshop.cdn.nintendo.net/i/f82902db3c1f0b19b1e00c324aba9509c0f9ebec784bcd249e21cffc39151a4e.jpg', '', '88%', NULL, ''),
(1604, 'Persona 4 Golden', 'Jun 13, 2020', '93', '93', 'JRPG', 'https://www.metacritic.com/game/persona-4-golden/', '2025-10-03 06:11:57', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1113000/capsule_616x353.jpg?t=1704380046', '', '100%', NULL, ''),
(1605, 'BeamNG.drive', 'Sep 27, 2024', 'tbd', 'tbd', 'Auto Racing Sim', 'https://www.metacritic.com/game/beamngdrive/', '2025-10-03 06:12:00', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTsVdH7hgac-OaipmOwXItjyPBXvmSaH7ecng&s', '', '90%', NULL, ''),
(1606, 'Cyberpunk 2077: Phantom Liberty', 'Sep 26, 2023', '89', '89', 'Action RPG', 'https://www.metacritic.com/game/cyberpunk-2077-phantom-liberty/', '2025-10-03 06:12:03', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSO9F5-2AyWcGACpFzWKdGCpo3_saC6dUuNAA&s', '', '98%', NULL, ''),
(1607, 'Chained Echoes', 'Dec 8, 2022', '90', '90', 'JRPG', 'https://www.metacritic.com/game/chained-echoes/', '2025-10-03 06:12:04', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1229240/header.jpg?t=1755241379', '', '93%', NULL, ''),
(1608, 'HoloCure - Save the Fans!', 'Aug 16, 2023', 'tbd', 'tbd', 'Top-Down Shoot-\'Em-Up', 'https://www.metacritic.com/game/holocure-save-the-fans/', '2025-10-03 06:12:07', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2420510/bf8baa346b174a0d904e0940f993ada10a06d3ae/capsule_616x353.jpg?t=1740642230', '', '89%', NULL, ''),
(1609, 'Anomaly Agent', 'Jan 24, 2024', '84', '84', '2D Platformer', 'https://www.metacritic.com/game/anomaly-agent/', '2025-10-03 06:12:16', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2378620/capsule_616x353.jpg?t=1755078189', '', '82%', NULL, ''),
(1610, 'Deltarune: Chapter 2', 'Sep 17, 2021', 'tbd', 'tbd', 'JRPG', 'https://www.metacritic.com/game/deltarune-chapter-2/', '2025-10-03 06:12:19', 'https://i.scdn.co/image/ab67616d0000b2734e48efe54e29fa5dc5e0a0d6', '', '91%', NULL, '');

-- --------------------------------------------------------

--
-- Table structure for table `steam_games`
--

CREATE TABLE `steam_games` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `genre` varchar(100) DEFAULT NULL,
  `price` varchar(255) DEFAULT NULL,
  `discount` varchar(50) DEFAULT NULL,
  `players` varchar(255) DEFAULT NULL,
  `release_date` varchar(255) DEFAULT NULL,
  `url` text DEFAULT NULL,
  `image_url` text DEFAULT NULL,
  `user_review` varchar(10) NOT NULL,
  `last_scraped` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `steam_appid` varchar(50) DEFAULT NULL,
  `review_percent` int(11) DEFAULT NULL,
  `review_count` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `steam_games`
--

INSERT INTO `steam_games` (`id`, `title`, `genre`, `price`, `discount`, `players`, `release_date`, `url`, `image_url`, `user_review`, `last_scraped`, `steam_appid`, `review_percent`, `review_count`) VALUES
(626, 'Aseprite', 'Animation & Modeling, Animation & Modeling, Design & Illustration, Game Development', '฿231.20', '20%', '4073', '22 Feb, 2016', 'https://store.steampowered.com/app/431730/Aseprite/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/431730/capsule_231x87.jpg?t=1749680273', '', '2025-10-03 12:41:31', '431730', 99, 99),
(627, 'A Short Hike', 'Indie Games, Adventure, Indie', '฿87.45', '45%', '34', '30 Jul, 2019', 'https://store.steampowered.com/app/1055540/A_Short_Hike/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1055540/df88a75bc65beb0d4bea2d52fa6718f8b5b6e35e/capsule_231x87.jpg?t=1755182478', '', '2025-10-03 12:41:31', '1055540', 99, 99),
(628, 'Papa\'s Freezeria Deluxe', 'Strategy Games, Action, Casual, Indie, Simulation, Strategy', '฿108.00', '20%', '102', '31 Mar, 2023', 'https://store.steampowered.com/app/2291760/Papas_Freezeria_Deluxe/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2291760/capsule_231x87.jpg?t=1700157490', '', '2025-10-03 12:41:31', '2291760', 99, 99),
(629, 'Ib', 'Adventure Games, Adventure, Indie', '฿219.00', '0%', '12', '11 Apr, 2022', 'https://store.steampowered.com/app/1901370/Ib/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1901370/capsule_231x87.jpg?t=1735124072', '', '2025-10-03 12:41:31', '1901370', 99, 99),
(630, 'Patrick\'s Parabox', 'Indie Games, Casual, Indie, Strategy', '฿240.00', '40%', '79', '29 Mar, 2022', 'https://store.steampowered.com/app/1260520/Patricks_Parabox/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1260520/capsule_231x87.jpg?t=1745611653', '', '2025-10-03 12:41:31', '1260520', 99, 99),
(631, 'Kabuto Park', 'Casual Games, Casual, Indie, RPG, Simulation, Strategy', '฿92.00', '20%', '9', '28 May, 2025', 'https://store.steampowered.com/app/3376990/Kabuto_Park/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3376990/46fc170c99b88a84a6125c2110391f4a9c6108b2/capsule_231x87.jpg?t=1759313308', '', '2025-10-03 12:41:31', '3376990', 99, 99),
(632, 'Strange Jigsaws', 'Adventure Games, Adventure, Casual, Indie', '฿92.00', '20%', '23', '7 Aug, 2025', 'https://store.steampowered.com/app/2702170/Strange_Jigsaws/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2702170/f983f1d7697648e90c072463f1a995e6c772c042/capsule_231x87.jpg?t=1754937353', '', '2025-10-03 12:41:31', '2702170', 100, 100),
(633, 'Monster Prom 4: Monster Con', 'Indie Games, Casual, Indie, Simulation, Strategy', '฿267.75', '15%', '26', '24 Apr, 2025', 'https://store.steampowered.com/app/2869860/Monster_Prom_4_Monster_Con/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2869860/b8a2ecb62b85dd26e827f2ff20e1cf007a439e4d/capsule_231x87.jpg?t=1751011133', '', '2025-10-03 12:41:31', '2869860', 96, 96),
(634, 'Higurashi When They Cry Hou - Ch.6 Tsumihoroboshi', 'Adventure Games, Adventure', '฿103.35', '35%', '11', '14 Jun, 2018', 'https://store.steampowered.com/app/668350/Higurashi_When_They_Cry_Hou__Ch6_Tsumihoroboshi/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/668350/capsule_231x87.jpg?t=1725522856', '', '2025-10-03 12:41:31', '668350', 91, 91),
(635, 'DEVIL BLADE REBOOT', 'Action Games, Action, Indie', '฿247.50', '25%', '1', '23 May, 2024', 'https://store.steampowered.com/app/2882440/DEVIL_BLADE_REBOOT/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2882440/capsule_231x87.jpg?t=1744690482', '', '2025-10-03 12:41:31', '2882440', 100, 100),
(636, 'Don\'t Escape Trilogy', 'Adventure Games, Adventure, Indie', '฿28.75', '75%', '1', '29 Jul, 2019', 'https://store.steampowered.com/app/1070550/Dont_Escape_Trilogy/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1070550/capsule_231x87.jpg?t=1726580834', '', '2025-10-03 12:41:31', '1070550', 100, 100),
(637, 'Wallpaper Engine', 'Utilities, Casual, Indie, Animation & Modeling, Design & Illustration, Photo Editing, Utilities', '฿92.00', '20%', '94029', '16 Nov, 2018', 'https://store.steampowered.com/app/431960/Wallpaper_Engine/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/431960/capsule_231x87.jpg?t=1739211362', '', '2025-10-03 12:41:31', '431960', 98, 98),
(638, 'Stardew Valley', 'Indie Games, Indie, RPG, Simulation', '฿220.50', '30%', '64698', '26 Feb, 2016', 'https://store.steampowered.com/app/413150/Stardew_Valley/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/413150/capsule_231x87.jpg?t=1754692865', '', '2025-10-03 12:41:31', '413150', 98, 98),
(639, 'Portal 2', 'Action Games, Action, Adventure', '฿44.00', '80%', '1266', '18 Apr, 2011', 'https://store.steampowered.com/app/620/Portal_2/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/620/capsule_231x87.jpg?t=1745363004', '', '2025-10-03 12:41:31', '620', 98, 98),
(640, 'People Playground', 'Simulation Games, Action, Casual, Indie, Simulation', '฿189.00', '0%', '2489', '23 Jul, 2019', 'https://store.steampowered.com/app/1118200/People_Playground/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1118200/capsule_231x87.jpg?t=1717246983', '', '2025-10-03 12:41:31', '1118200', 98, 98),
(641, 'Hades', 'Action Games, Action, Indie, RPG', '฿123.75', '75%', '10482', '17 Sep, 2020', 'https://store.steampowered.com/app/1145360/Hades/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1145360/capsule_231x87.jpg?t=1758127023', '', '2025-10-03 12:41:31', '1145360', 98, 98),
(642, 'Vampire Survivors', 'Action Games, Action, Casual, Indie, RPG', '฿89.25', '25%', '2918', '20 Oct, 2022', 'https://store.steampowered.com/app/1794680/Vampire_Survivors/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1794680/capsule_231x87.jpg?t=1758902954', '', '2025-10-03 12:41:31', '1794680', 98, 98),
(643, 'Schedule I', 'Action Games, Action, Indie, Simulation, Strategy, Early Access', '฿280.00', '30%', '9905', '24 Mar, 2025', 'https://store.steampowered.com/app/3164500/Schedule_I/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3164500/986ee9a7a25cb0e61d1530cc3cd7e3e06aa68733/capsule_231x87.jpg?t=1751926051', '', '2025-10-03 12:41:31', '3164500', 98, 98),
(644, 'Portal', 'Action Games, Action', '฿44.00', '80%', '407', '10 Oct, 2007', 'https://store.steampowered.com/app/400/Portal/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/400/capsule_231x87.jpg?t=1745368554', '', '2025-10-03 12:41:31', '400', 98, 98),
(645, 'Half-Life: Alyx', 'Action Games, Action, Adventure', '฿330.00', '70%', '224', '23 Mar, 2020', 'https://store.steampowered.com/app/546560/HalfLife_Alyx/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/546560/capsule_231x87.jpg?t=1673391297', '', '2025-10-03 12:41:31', '546560', 98, 98),
(646, 'DELTARUNE', 'RPG Games, Indie, RPG', '฿499.00', '0%', '1227', '4 Jun, 2025', 'https://store.steampowered.com/app/1671210/DELTARUNE/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1671210/capsule_231x87.jpg?t=1749252480', '', '2025-10-03 12:41:31', '1671210', 98, 98),
(647, 'Katana ZERO', 'Indie Games, Action, Indie', '฿189.00', '40%', '112', '18 Apr, 2019', 'https://store.steampowered.com/app/460950/Katana_ZERO/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/460950/capsule_231x87.jpg?t=1759429315', '', '2025-10-03 12:41:31', '460950', 97, 97),
(648, 'OneShot', 'Indie Games, Adventure, Casual, Indie', '฿132.00', '40%', '63', '8 Dec, 2016', 'https://store.steampowered.com/app/420530/OneShot/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/420530/capsule_231x87.jpg?t=1747673318', '', '2025-10-03 12:41:31', '420530', 98, 98),
(649, 'The Henry Stickmin Collection', 'Adventure Games, Adventure, Casual, Indie', '฿119.60', '60%', '102', '7 Aug, 2020', 'https://store.steampowered.com/app/1089980/The_Henry_Stickmin_Collection/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1089980/capsule_231x87.jpg?t=1619212064', '', '2025-10-03 12:41:31', '1089980', 98, 98),
(650, 'Senren＊Banka', 'Adventure Games, Adventure, Casual', '฿238.83', '43%', '679', '14 Feb, 2020', 'https://store.steampowered.com/app/1144400/SenrenBanka/?snr=1_7_7_7000_150_1', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1144400/capsule_231x87.jpg?t=1752128014', '', '2025-10-03 12:41:31', '1144400', 95, 95),
(651, 'Touhou Mystia\'s Izakaya', 'RPG Games, Casual, Indie, RPG, Simulation', '฿116.80', '46%', '1062', '1 Oct, 2021', 'https://store.steampowered.com/app/1584090/Touhou_Mystias_Izakaya/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1584090/capsule_231x87.jpg?t=1754756547', '', '2025-10-03 12:41:31', '1584090', 98, 98),
(652, 'Chants of Sennaar', 'Indie Games, Adventure, Indie', '฿294.00', '40%', '237', '5 Sep, 2023', 'https://store.steampowered.com/app/1931770/Chants_of_Sennaar/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1931770/capsule_231x87.jpg?t=1755089409', '', '2025-10-03 12:41:31', '1931770', 98, 98),
(653, 'ATRI -My Dear Moments-', 'Adventure Games, Adventure, Casual', '฿136.35', '55%', '87', '18 Jun, 2020', 'https://store.steampowered.com/app/1230140/ATRI_My_Dear_Moments/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1230140/capsule_231x87.jpg?t=1736225576', '', '2025-10-03 12:41:31', '1230140', 97, 97),
(654, 'Rhythm Doctor', 'Indie Games, Indie, Early Access', '฿297.00', '10%', '153', '26 Feb, 2021', 'https://store.steampowered.com/app/774181/Rhythm_Doctor/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/774181/capsule_231x87.jpg?t=1759046100', '', '2025-10-03 12:41:31', '774181', 98, 98),
(655, 'VTOL VR', 'Action Games, Action, Indie, Simulation', '฿363.35', '35%', '129', '3 Aug, 2017', 'https://store.steampowered.com/app/667970/VTOL_VR/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/667970/d42ac6861288565220376e3dc4474c11fa18f091/capsule_231x87.jpg?t=1732654698', '', '2025-10-03 12:41:31', '667970', 98, 98),
(656, 'The Room 4: Old Sins', 'Adventure Games, Adventure', '฿70.00', '60%', '44', '11 Feb, 2021', 'https://store.steampowered.com/app/1361320/The_Room_4_Old_Sins/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1361320/capsule_231x87.jpg?t=1646758366', '', '2025-10-03 12:41:31', '1361320', 98, 98),
(657, 'Neon White', 'Action Games, Action, Adventure, Indie', '฿229.50', '50%', '84', '16 Jun, 2022', 'https://store.steampowered.com/app/1533420/Neon_White/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1533420/capsule_231x87.jpg?t=1729099604', '', '2025-10-03 12:41:31', '1533420', 98, 98),
(658, 'Wobbledogs', 'Simulation Games, Casual, Indie, Simulation', '฿98.26', '66%', '72', '15 Mar, 2022', 'https://store.steampowered.com/app/1424330/Wobbledogs/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1424330/capsule_231x87.jpg?t=1758272887', '', '2025-10-03 12:41:31', '1424330', 98, 98),
(659, 'Tactical Breach Wizards', 'Strategy Games, Adventure, Indie, RPG, Strategy', '฿280.00', '30%', '67', '22 Aug, 2024', 'https://store.steampowered.com/app/1043810/Tactical_Breach_Wizards/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1043810/capsule_231x87.jpg?t=1743032524', '', '2025-10-03 12:41:31', '1043810', 98, 98),
(660, 'Trombone Champ', 'Indie Games, Casual, Indie', '฿83.65', '65%', '70', '15 Sep, 2022', 'https://store.steampowered.com/app/1059990/Trombone_Champ/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1059990/capsule_231x87.jpg?t=1743798831', '', '2025-10-03 12:41:31', '1059990', 98, 98),
(661, 'The Case of the Golden Idol', 'Indie Games, Adventure, Indie', '฿134.50', '50%', '78', '13 Oct, 2022', 'https://store.steampowered.com/app/1677770/The_Case_of_the_Golden_Idol/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1677770/capsule_231x87.jpg?t=1758227116', '', '2025-10-03 12:41:31', '1677770', 98, 98),
(662, 'Hylics', 'RPG Games, Indie, RPG', '฿22.77', '67%', '15', '2 Oct, 2015', 'https://store.steampowered.com/app/397740/Hylics/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/397740/capsule_231x87.jpg?t=1447377715', '', '2025-10-03 12:41:31', '397740', 98, 98),
(663, 'Lost in Play', 'Indie Games, Adventure, Indie', '฿120.00', '70%', '47', '10 Aug, 2022', 'https://store.steampowered.com/app/1328840/Lost_in_Play/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1328840/capsule_231x87.jpg?t=1758210737', '', '2025-10-03 12:41:31', '1328840', 97, 97),
(664, 'Crow Country', 'Action Games, Action, Indie', '฿240.00', '40%', '36', '9 May, 2024', 'https://store.steampowered.com/app/1996010/Crow_Country/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1996010/capsule_231x87.jpg?t=1752238470', '', '2025-10-03 12:41:31', '1996010', 98, 98),
(665, 'WITCH ON THE HOLY NIGHT', 'Adventure Games, Adventure', '฿660.00', '40%', '125', '14 Dec, 2023', 'https://store.steampowered.com/app/2052410/WITCH_ON_THE_HOLY_NIGHT/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2052410/capsule_231x87.jpg?t=1753952335', '', '2025-10-03 12:41:31', '2052410', 97, 97),
(666, 'Epic Battle Fantasy 5', 'RPG Games, Adventure, RPG, Strategy', '฿160.00', '60%', '64', '30 Nov, 2018', 'https://store.steampowered.com/app/432350/Epic_Battle_Fantasy_5/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/432350/capsule_231x87.jpg?t=1720824507', '', '2025-10-03 12:41:31', '432350', 99, 99),
(667, 'Look Outside', 'Adventure Games, Adventure, RPG', '฿176.00', '20%', '275', '21 Mar, 2025', 'https://store.steampowered.com/app/3373660/Look_Outside/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3373660/e0dae146ff3f347de7f3d26d3cc59977a675cfd9/capsule_231x87.jpg?t=1757969521', '', '2025-10-03 12:41:31', '3373660', 98, 98),
(668, 'I Wani Hug that Gator!', 'Indie Games, Casual, Indie', '฿189.00', '40%', '17', '14 Feb, 2024', 'https://store.steampowered.com/app/1895350/I_Wani_Hug_that_Gator/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1895350/capsule_231x87.jpg?t=1749719297', '', '2025-10-03 12:41:31', '1895350', 98, 98),
(669, 'Summer Pockets', 'Casual Games, Adventure, Casual', '฿207.60', '60%', '38', '29 Jun, 2018', 'https://store.steampowered.com/app/897220/Summer_Pockets/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/897220/capsule_231x87.jpg?t=1732683225', '', '2025-10-03 12:41:31', '897220', 96, 96),
(670, 'Lil Gator Game', 'Adventure Games, Action, Adventure, Casual, Indie', '฿200.00', '50%', '18', '14 Dec, 2022', 'https://store.steampowered.com/app/1586800/Lil_Gator_Game/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1586800/capsule_231x87.jpg?t=1736949285', '', '2025-10-03 12:41:31', '1586800', 99, 99),
(671, 'Picayune Dreams', 'Action Games, Action', '฿43.55', '33%', '27', '4 Dec, 2023', 'https://store.steampowered.com/app/2088840/Picayune_Dreams/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2088840/capsule_231x87.jpg?t=1740588801', '', '2025-10-03 12:41:31', '2088840', 98, 98),
(672, 'BRAZILIAN DRUG DEALER 3: I OPENED A PORTAL TO HELL IN THE FAVELA TRYING TO REVIVE MIT AIA I NEED TO CLOSE IT', 'Action Games, Action, Adventure, Indie', '฿115.00', '0%', '22', '17 Sep, 2025', 'https://store.steampowered.com/app/3191050/BRAZILIAN_DRUG_DEALER_3_I_OPENED_A_PORTAL_TO_HELL_IN_THE_FAVELA_TRYING_TO_REVIVE_MIT_AIA_I_NEED_TO_CLOSE_IT/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3191050/9aaee06e6d351e297cfa6164306de149427fe53c/capsule_231x87_alt_assets_1.jpg?t=1759361442', '', '2025-10-03 12:41:31', '3191050', 98, 98),
(673, 'planetarian HD', 'Casual Games, Adventure, Casual, Simulation', '฿87.60', '60%', '3', '8 May, 2017', 'https://store.steampowered.com/app/623080/planetarian_HD/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/623080/capsule_231x87.jpg?t=1732683288', '', '2025-10-03 12:41:31', '623080', 97, 97),
(674, 'Monster Prom 3: Monster Roadtrip', 'Indie Games, Casual, Indie, Simulation, Strategy', '฿83.60', '60%', '11', '21 Oct, 2022', 'https://store.steampowered.com/app/1665190/Monster_Prom_3_Monster_Roadtrip/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1665190/capsule_231x87.jpg?t=1746716762', '', '2025-10-03 12:41:31', '1665190', 98, 98),
(675, 'Epic Battle Fantasy 4', 'RPG Games, Adventure, RPG', '฿90.00', '70%', '15', '25 Feb, 2014', 'https://store.steampowered.com/app/265610/Epic_Battle_Fantasy_4/?snr=1_7_7_7000_150_2', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/265610/capsule_231x87.jpg?t=1722446987', '', '2025-10-03 12:41:31', '265610', 97, 97);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `metacritic_games`
--
ALTER TABLE `metacritic_games`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `steam_games`
--
ALTER TABLE `steam_games`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `metacritic_games`
--
ALTER TABLE `metacritic_games`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1611;

--
-- AUTO_INCREMENT for table `steam_games`
--
ALTER TABLE `steam_games`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=726;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
