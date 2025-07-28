/*
 Navicat Premium Data Transfer

 Source Server         : VeggieVision
 Source Server Type    : MySQL
 Source Server Version : 80033
 Source Host           : localhost:3306
 Source Schema         : veggievision_db

 Target Server Type    : MySQL
 Target Server Version : 80033
 File Encoding         : 65001

 Date: 28/07/2025 19:48:30
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for auth_group
-- ----------------------------
DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE `auth_group`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_group
-- ----------------------------

-- ----------------------------
-- Table structure for auth_group_permissions
-- ----------------------------
DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE `auth_group_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_group_permissions_group_id_permission_id_0cd325b0_uniq`(`group_id`, `permission_id`) USING BTREE,
  INDEX `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm`(`permission_id`) USING BTREE,
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_group_permissions
-- ----------------------------

-- ----------------------------
-- Table structure for auth_permission
-- ----------------------------
DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE `auth_permission`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_permission_content_type_id_codename_01ab375a_uniq`(`content_type_id`, `codename`) USING BTREE,
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_permission
-- ----------------------------
INSERT INTO `auth_permission` VALUES (1, 'Can add log entry', 1, 'add_logentry');
INSERT INTO `auth_permission` VALUES (2, 'Can change log entry', 1, 'change_logentry');
INSERT INTO `auth_permission` VALUES (3, 'Can delete log entry', 1, 'delete_logentry');
INSERT INTO `auth_permission` VALUES (4, 'Can view log entry', 1, 'view_logentry');
INSERT INTO `auth_permission` VALUES (5, 'Can add permission', 2, 'add_permission');
INSERT INTO `auth_permission` VALUES (6, 'Can change permission', 2, 'change_permission');
INSERT INTO `auth_permission` VALUES (7, 'Can delete permission', 2, 'delete_permission');
INSERT INTO `auth_permission` VALUES (8, 'Can view permission', 2, 'view_permission');
INSERT INTO `auth_permission` VALUES (9, 'Can add group', 3, 'add_group');
INSERT INTO `auth_permission` VALUES (10, 'Can change group', 3, 'change_group');
INSERT INTO `auth_permission` VALUES (11, 'Can delete group', 3, 'delete_group');
INSERT INTO `auth_permission` VALUES (12, 'Can view group', 3, 'view_group');
INSERT INTO `auth_permission` VALUES (13, 'Can add content type', 4, 'add_contenttype');
INSERT INTO `auth_permission` VALUES (14, 'Can change content type', 4, 'change_contenttype');
INSERT INTO `auth_permission` VALUES (15, 'Can delete content type', 4, 'delete_contenttype');
INSERT INTO `auth_permission` VALUES (16, 'Can view content type', 4, 'view_contenttype');
INSERT INTO `auth_permission` VALUES (17, 'Can add session', 5, 'add_session');
INSERT INTO `auth_permission` VALUES (18, 'Can change session', 5, 'change_session');
INSERT INTO `auth_permission` VALUES (19, 'Can delete session', 5, 'delete_session');
INSERT INTO `auth_permission` VALUES (20, 'Can view session', 5, 'view_session');
INSERT INTO `auth_permission` VALUES (21, 'Can add 用户', 6, 'add_customuser');
INSERT INTO `auth_permission` VALUES (22, 'Can change 用户', 6, 'change_customuser');
INSERT INTO `auth_permission` VALUES (23, 'Can delete 用户', 6, 'delete_customuser');
INSERT INTO `auth_permission` VALUES (24, 'Can view 用户', 6, 'view_customuser');
INSERT INTO `auth_permission` VALUES (25, 'Can add image', 7, 'add_image');
INSERT INTO `auth_permission` VALUES (26, 'Can change image', 7, 'change_image');
INSERT INTO `auth_permission` VALUES (27, 'Can delete image', 7, 'delete_image');
INSERT INTO `auth_permission` VALUES (28, 'Can view image', 7, 'view_image');
INSERT INTO `auth_permission` VALUES (29, 'Can add grading result', 8, 'add_gradingresult');
INSERT INTO `auth_permission` VALUES (30, 'Can change grading result', 8, 'change_gradingresult');
INSERT INTO `auth_permission` VALUES (31, 'Can delete grading result', 8, 'delete_gradingresult');
INSERT INTO `auth_permission` VALUES (32, 'Can view grading result', 8, 'view_gradingresult');
INSERT INTO `auth_permission` VALUES (33, 'Can add Token', 9, 'add_token');
INSERT INTO `auth_permission` VALUES (34, 'Can change Token', 9, 'change_token');
INSERT INTO `auth_permission` VALUES (35, 'Can delete Token', 9, 'delete_token');
INSERT INTO `auth_permission` VALUES (36, 'Can view Token', 9, 'view_token');
INSERT INTO `auth_permission` VALUES (37, 'Can add Token', 10, 'add_tokenproxy');
INSERT INTO `auth_permission` VALUES (38, 'Can change Token', 10, 'change_tokenproxy');
INSERT INTO `auth_permission` VALUES (39, 'Can delete Token', 10, 'delete_tokenproxy');
INSERT INTO `auth_permission` VALUES (40, 'Can view Token', 10, 'view_tokenproxy');

-- ----------------------------
-- Table structure for authtoken_token
-- ----------------------------
DROP TABLE IF EXISTS `authtoken_token`;
CREATE TABLE `authtoken_token`  (
  `key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created` datetime(6) NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`key`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id`) USING BTREE,
  CONSTRAINT `authtoken_token_user_id_35299eff_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of authtoken_token
-- ----------------------------
INSERT INTO `authtoken_token` VALUES ('d42c7a910d09d185ac8a19e36a3f79c6979a4e4d', '2025-06-06 03:20:46.449326', 2);

-- ----------------------------
-- Table structure for django_admin_log
-- ----------------------------
DROP TABLE IF EXISTS `django_admin_log`;
CREATE TABLE `django_admin_log`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `object_repr` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `action_flag` smallint UNSIGNED NOT NULL,
  `change_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content_type_id` int NULL DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `django_admin_log_content_type_id_c4bce8eb_fk_django_co`(`content_type_id`) USING BTREE,
  INDEX `django_admin_log_user_id_c564eba6_fk_users_id`(`user_id`) USING BTREE,
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_admin_log
-- ----------------------------
INSERT INTO `django_admin_log` VALUES (1, '2025-06-02 14:03:55.460807', '57', 'GradingResult object (57)', 1, '[{\"added\": {}}]', 8, 2);
INSERT INTO `django_admin_log` VALUES (2, '2025-06-02 14:06:15.624164', '57', 'GradingResult object (57)', 3, '', 8, 2);

-- ----------------------------
-- Table structure for django_content_type
-- ----------------------------
DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE `django_content_type`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `django_content_type_app_label_model_76bd3d3b_uniq`(`app_label`, `model`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_content_type
-- ----------------------------
INSERT INTO `django_content_type` VALUES (1, 'admin', 'logentry');
INSERT INTO `django_content_type` VALUES (3, 'auth', 'group');
INSERT INTO `django_content_type` VALUES (2, 'auth', 'permission');
INSERT INTO `django_content_type` VALUES (9, 'authtoken', 'token');
INSERT INTO `django_content_type` VALUES (10, 'authtoken', 'tokenproxy');
INSERT INTO `django_content_type` VALUES (4, 'contenttypes', 'contenttype');
INSERT INTO `django_content_type` VALUES (8, 'grading', 'gradingresult');
INSERT INTO `django_content_type` VALUES (7, 'grading', 'image');
INSERT INTO `django_content_type` VALUES (5, 'sessions', 'session');
INSERT INTO `django_content_type` VALUES (6, 'users', 'customuser');

-- ----------------------------
-- Table structure for django_migrations
-- ----------------------------
DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE `django_migrations`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_migrations
-- ----------------------------
INSERT INTO `django_migrations` VALUES (1, 'contenttypes', '0001_initial', '2025-03-21 08:08:29.940994');
INSERT INTO `django_migrations` VALUES (2, 'contenttypes', '0002_remove_content_type_name', '2025-03-21 08:08:29.965764');
INSERT INTO `django_migrations` VALUES (3, 'auth', '0001_initial', '2025-03-21 08:08:30.062833');
INSERT INTO `django_migrations` VALUES (4, 'auth', '0002_alter_permission_name_max_length', '2025-03-21 08:08:30.084539');
INSERT INTO `django_migrations` VALUES (5, 'auth', '0003_alter_user_email_max_length', '2025-03-21 08:08:30.088551');
INSERT INTO `django_migrations` VALUES (6, 'auth', '0004_alter_user_username_opts', '2025-03-21 08:08:30.105510');
INSERT INTO `django_migrations` VALUES (7, 'auth', '0005_alter_user_last_login_null', '2025-03-21 08:08:30.108539');
INSERT INTO `django_migrations` VALUES (8, 'auth', '0006_require_contenttypes_0002', '2025-03-21 08:08:30.109673');
INSERT INTO `django_migrations` VALUES (9, 'auth', '0007_alter_validators_add_error_messages', '2025-03-21 08:08:30.113184');
INSERT INTO `django_migrations` VALUES (10, 'auth', '0008_alter_user_username_max_length', '2025-03-21 08:08:30.116989');
INSERT INTO `django_migrations` VALUES (11, 'auth', '0009_alter_user_last_name_max_length', '2025-03-21 08:08:30.121361');
INSERT INTO `django_migrations` VALUES (12, 'auth', '0010_alter_group_name_max_length', '2025-03-21 08:08:30.129107');
INSERT INTO `django_migrations` VALUES (13, 'auth', '0011_update_proxy_permissions', '2025-03-21 08:08:30.132616');
INSERT INTO `django_migrations` VALUES (14, 'auth', '0012_alter_user_first_name_max_length', '2025-03-21 08:08:30.135673');
INSERT INTO `django_migrations` VALUES (15, 'users', '0001_initial', '2025-03-21 08:08:30.250352');
INSERT INTO `django_migrations` VALUES (16, 'admin', '0001_initial', '2025-03-21 08:08:30.309770');
INSERT INTO `django_migrations` VALUES (17, 'admin', '0002_logentry_remove_auto_add', '2025-03-21 08:08:30.314131');
INSERT INTO `django_migrations` VALUES (18, 'admin', '0003_logentry_add_action_flag_choices', '2025-03-21 08:08:30.319691');
INSERT INTO `django_migrations` VALUES (19, 'sessions', '0001_initial', '2025-03-21 08:08:30.336100');
INSERT INTO `django_migrations` VALUES (20, 'authtoken', '0001_initial', '2025-03-21 11:49:01.013736');
INSERT INTO `django_migrations` VALUES (21, 'authtoken', '0002_auto_20160226_1747', '2025-03-21 11:49:01.029162');
INSERT INTO `django_migrations` VALUES (22, 'authtoken', '0003_tokenproxy', '2025-03-21 11:49:01.031205');
INSERT INTO `django_migrations` VALUES (23, 'authtoken', '0004_alter_tokenproxy_options', '2025-03-21 11:49:01.033257');
INSERT INTO `django_migrations` VALUES (25, 'grading', '0002_alter_graderule_category_and_more', '2025-04-04 12:14:17.093981');
INSERT INTO `django_migrations` VALUES (26, 'grading', '0003_alter_graderule_options', '2025-04-04 12:20:09.686653');
INSERT INTO `django_migrations` VALUES (28, 'grading', '0001_initial', '2025-04-11 14:51:30.836424');
INSERT INTO `django_migrations` VALUES (29, 'grading', '0002_auto_20240520', '2025-04-11 14:51:30.840531');
INSERT INTO `django_migrations` VALUES (30, 'grading', '0002_alter_graderule_options_and_more', '2025-05-20 13:33:13.156760');
INSERT INTO `django_migrations` VALUES (31, 'grading', '0003_remove_gradingresult_grade_rule_and_more', '2025-05-20 13:54:21.910658');
INSERT INTO `django_migrations` VALUES (32, 'grading', '0004_alter_gradingresult_options_gradingresult_source_and_more', '2025-05-23 06:29:36.843468');
INSERT INTO `django_migrations` VALUES (33, 'grading', '0002_alter_gradingresult_options_and_more', '2025-05-23 13:54:37.117428');
INSERT INTO `django_migrations` VALUES (34, 'grading', '0002_image_image_name', '2025-05-23 15:17:04.581833');
INSERT INTO `django_migrations` VALUES (35, 'grading', '0002_alter_image_image_file', '2025-05-31 06:53:28.759914');
INSERT INTO `django_migrations` VALUES (36, 'grading', '0003_image_original_url', '2025-06-01 14:25:00.250854');
INSERT INTO `django_migrations` VALUES (37, 'grading', '0004_remove_image_original_url', '2025-06-01 14:51:50.103508');

-- ----------------------------
-- Table structure for django_session
-- ----------------------------
DROP TABLE IF EXISTS `django_session`;
CREATE TABLE `django_session`  (
  `session_key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `session_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`) USING BTREE,
  INDEX `django_session_expire_date_a5c62663`(`expire_date`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_session
-- ----------------------------
INSERT INTO `django_session` VALUES ('xng84dv4crvqi39chm0pb7rzl42pamnc', '.eJxVjEEOwiAQAP_C2RCgWygevfcNzS67SNXQpLQn499Nkx70OjOZt5pw38q0N1mnmdVVOXX5ZYTpKfUQ_MB6X3Ra6rbOpI9En7bpcWF53c72b1CwlWPb-zwYCBQDpQwGqRu8BEgGJEfr2aAkBGEbOPZkO3KCHTqMjBZ8UJ8v7BY4Vw:1uM5rX:de5zPzvz1UKzF1lwq01QcRjOZrkwYAb6oMO77yAGbM8', '2025-06-16 14:10:03.411387');

-- ----------------------------
-- Table structure for grading_gradingresult
-- ----------------------------
DROP TABLE IF EXISTS `grading_gradingresult`;
CREATE TABLE `grading_gradingresult`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `final_grade` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` bigint NOT NULL,
  `image_id` bigint NOT NULL,
  `confidence` double NOT NULL,
  `detected_label` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `source` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `grading_gradingresult_image_id_d8be9e8c_fk_image_id`(`image_id`) USING BTREE,
  CONSTRAINT `grading_gradingresult_image_id_d8be9e8c_fk_image_id` FOREIGN KEY (`image_id`) REFERENCES `image` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 78 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of grading_gradingresult
-- ----------------------------
INSERT INTO `grading_gradingresult` VALUES (46, '合格', '2025-06-01 15:43:51.210443', 2, 62, 0.956, 'persimmon_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (47, '合格', '2025-06-01 16:14:25.697762', 2, 63, 0.9521, 'apple_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (48, '合格', '2025-06-01 16:15:37.446856', 2, 64, 0.977, 'pear_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (49, '合格', '2025-06-01 16:17:15.367111', 2, 65, 0.9631, 'carrot_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (50, '不合格', '2025-06-01 16:18:22.358755', 2, 66, 0.9735, 'mango_disqualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (51, '不合格', '2025-06-01 16:19:09.506888', 2, 67, 0.9539, 'papaya_disqualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (52, '合格', '2025-06-02 05:52:35.321762', 2, 68, 0.9595, 'orange_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (53, '合格', '2025-06-02 05:53:47.981858', 2, 69, 0.9813, 'orange_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (54, '合格', '2025-06-02 13:35:15.679168', 2, 70, 0.6692, 'apple_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (55, '不合格', '2025-06-02 13:35:52.509734', 2, 71, 0.6531, 'watermelon_disqualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (56, '合格', '2025-06-02 13:48:12.613332', 1, 72, 0.9849, 'orange_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (58, '合格', '2025-06-02 14:19:47.122461', 1, 73, 0.9738, 'orange_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (59, '合格', '2025-06-02 14:20:38.504822', 2, 74, 0.9738, 'orange_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (60, '合格', '2025-06-02 14:20:40.537448', 2, 74, 0.9738, 'orange_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (61, '合格', '2025-06-02 14:22:24.856501', 2, 75, 0.9684, 'orange_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (63, '合格', '2025-06-03 05:13:08.144715', 2, 77, 0.9482, 'apple_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (64, '合格', '2025-06-03 05:33:51.071202', 2, 78, 0.9498, 'grape_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (65, '合格', '2025-06-03 05:34:49.679073', 2, 79, 0.9531, 'apple_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (66, '合格', '2025-06-05 11:32:58.266273', 2, 80, 0.6567, 'banana_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (67, '合格', '2025-06-05 11:35:44.005317', 2, 81, 0.8786, 'apple_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (68, '合格', '2025-06-06 00:53:44.750710', 2, 82, 0.9322, 'apple_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (69, '不合格', '2025-06-06 00:54:00.210207', 2, 83, 0.9825, 'apple_disqualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (70, '合格', '2025-06-06 00:54:23.928071', 2, 84, 0.7528, 'banana_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (71, '合格', '2025-06-06 00:55:00.394232', 2, 85, 0.8584, 'radish_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (72, '合格', '2025-06-06 02:20:10.256993', 1, 86, 0.9119, 'grape_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (73, '合格', '2025-06-06 02:20:29.374487', 1, 87, 0.4006, 'banana_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (74, '合格', '2025-06-06 02:57:01.568970', 2, 88, 0.8778, 'banana_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (75, '合格', '2025-06-06 03:19:30.406431', 1, 89, 0.9498, 'grape_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (76, '不合格', '2025-06-06 03:19:47.909249', 1, 90, 0.9082, 'banana_disqualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (77, '合格', '2025-06-06 03:20:02.009914', 1, 91, 0.876, 'banana_qualified', 'upload');
INSERT INTO `grading_gradingresult` VALUES (78, '合格', '2025-06-06 03:25:18.455947', 2, 92, 0.7581, 'banana_qualified', 'upload');

-- ----------------------------
-- Table structure for image
-- ----------------------------
DROP TABLE IF EXISTS `image`;
CREATE TABLE `image`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `image_file` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `upload_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `image_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE,
  CONSTRAINT `image_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 92 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of image
-- ----------------------------
INSERT INTO `image` VALUES (62, 2, 'grading_images/2/20250601/5495d97d-4dcd-4ffa-a788-07e4205c1c96.jpg', '2025-06-01 15:43:50', 'upload.jpg');
INSERT INTO `image` VALUES (63, 2, 'grading_images/2/20250602/b4d3f3ce-07b2-4c1d-aecf-528f5e12c58c.jpg', '2025-06-01 16:14:21', 'upload.jpg');
INSERT INTO `image` VALUES (64, 2, 'grading_images/2/20250602/f4f8d007-8af7-44f6-a0a1-12d18b348eda.jpg', '2025-06-01 16:15:36', 'upload.jpg');
INSERT INTO `image` VALUES (65, 2, 'grading_images/2/20250602/6657fffc-fb5b-40d5-895c-c4366f98aff3.jpg', '2025-06-01 16:17:14', 'upload.jpg');
INSERT INTO `image` VALUES (66, 2, 'grading_images/2/20250602/39bbcf5b-76e3-400b-9a05-2804808284ea.jpg', '2025-06-01 16:18:21', 'upload.jpg');
INSERT INTO `image` VALUES (67, 2, 'grading_images/2/20250602/2b1af780-b450-4aa7-84b1-0e3c6f125f90.jpg', '2025-06-01 16:19:09', 'upload.jpg');
INSERT INTO `image` VALUES (68, 2, 'grading_images/2/20250602/547051a6-b329-4c7e-9f73-23df72a8bd97.jpg', '2025-06-02 05:52:30', 'upload.jpg');
INSERT INTO `image` VALUES (69, 2, 'grading_images/2/20250602/a36c4286-4aba-46c3-8dc3-9f0ae24c2dca.jpg', '2025-06-02 05:53:47', 'upload.jpg');
INSERT INTO `image` VALUES (70, 2, 'grading_images/2/20250602/e050fcfc-0df7-443e-bb61-4e0168fb363b.jpg', '2025-06-02 13:35:12', 'capture.jpg');
INSERT INTO `image` VALUES (71, 2, 'grading_images/2/20250602/d2aa0107-652d-45c1-b94e-b3dae9770161.jpg', '2025-06-02 13:35:52', 'capture.jpg');
INSERT INTO `image` VALUES (72, 1, 'grading_images/1/20250602/b98768c7-d9f8-4130-bc26-eeac2cf7e818.jpg', '2025-06-02 13:48:08', 'upload.jpg');
INSERT INTO `image` VALUES (73, 1, 'grading_images/1/20250602/fa379a9c-aa8f-4490-bb11-8fb28c4bf624.jpg', '2025-06-02 14:19:43', 'upload.jpg');
INSERT INTO `image` VALUES (74, 2, 'grading_images/2/20250602/345849dd-5c9a-41d5-8ae0-d3039293f027.jpg', '2025-06-02 14:20:37', 'upload.jpg');
INSERT INTO `image` VALUES (75, 2, 'grading_images/2/20250602/dc6200fa-6a2b-4c06-b39b-31847309effc.jpg', '2025-06-02 14:22:25', 'capture.jpg');
INSERT INTO `image` VALUES (76, 2, 'grading_images/2/20250603/44ec01d0-86b0-4182-9e3f-4c838eeffbe9.jpg', '2025-06-03 05:08:54', 'capture.jpg');
INSERT INTO `image` VALUES (77, 2, 'grading_images/2/20250603/67ed38f4-5987-4374-b2ca-fbe186cfe081.jpg', '2025-06-03 05:13:08', 'capture.jpg');
INSERT INTO `image` VALUES (78, 2, 'grading_images/2/20250603/1a347634-d940-484d-94b7-c552771a0b11.jpg', '2025-06-03 05:33:49', 'upload.jpg');
INSERT INTO `image` VALUES (79, 2, 'grading_images/2/20250603/35c6d70a-4d44-48e1-93de-f50f89a37af0.jpg', '2025-06-03 05:34:49', 'capture.jpg');
INSERT INTO `image` VALUES (80, 2, 'grading_images/2/20250605/991a9f6a-7a7c-41d3-977c-d75929c3e9fa.jpg', '2025-06-05 11:32:54', 'capture.jpg');
INSERT INTO `image` VALUES (81, 2, 'grading_images/2/20250605/28cc893c-7dfb-4c4c-af6b-b289b18c1350.jpg', '2025-06-05 11:35:44', 'capture.jpg');
INSERT INTO `image` VALUES (82, 2, 'grading_images/2/20250606/0caddace-a93b-4af1-a1db-b5f891f2b2e3.jpg', '2025-06-06 00:53:39', 'upload.jpg');
INSERT INTO `image` VALUES (83, 2, 'grading_images/2/20250606/bc478241-401e-40e1-b7a1-1bc43fb79384.jpg', '2025-06-06 00:53:58', 'upload.jpg');
INSERT INTO `image` VALUES (84, 2, 'grading_images/2/20250606/5858f2fe-6d1b-4d7a-a263-3e19af57f364.jpg', '2025-06-06 00:54:24', 'capture.jpg');
INSERT INTO `image` VALUES (85, 2, 'grading_images/2/20250606/5b9c48ef-246e-498f-92b2-789915e6f069.jpg', '2025-06-06 00:54:59', 'upload.jpg');
INSERT INTO `image` VALUES (86, 1, 'grading_images/1/20250606/baea6106-54bf-4afa-aa9d-2c3690ca75f6.jpg', '2025-06-06 02:20:06', 'upload.jpg');
INSERT INTO `image` VALUES (87, 1, 'grading_images/1/20250606/b38c4d9f-5f36-4126-b109-231e7d4b5152.jpg', '2025-06-06 02:20:29', 'capture.jpg');
INSERT INTO `image` VALUES (88, 2, 'grading_images/2/20250606/f420eabd-e3ab-4e5e-897d-c43db36a78b2.jpg', '2025-06-06 02:57:01', 'capture.jpg');
INSERT INTO `image` VALUES (89, 1, 'grading_images/1/20250606/9eba5272-0a8a-4eee-a54c-3f95131e55ec.jpg', '2025-06-06 03:19:28', 'upload.jpg');
INSERT INTO `image` VALUES (90, 1, 'grading_images/1/20250606/2571a751-0daa-4804-88bc-2dfae1017de6.jpg', '2025-06-06 03:19:46', 'upload.jpg');
INSERT INTO `image` VALUES (91, 1, 'grading_images/1/20250606/fb424f02-a6f6-4905-959c-16a5aba44158.jpg', '2025-06-06 03:20:02', 'capture.jpg');
INSERT INTO `image` VALUES (92, 2, 'grading_images/2/20250606/07bd860a-b0e9-4ae8-a3b1-05c2c2370aa7.jpg', '2025-06-06 03:25:18', 'capture.jpg');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `last_login` datetime(6) NULL DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `first_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `last_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'pbkdf2_sha256$870000$igOvmgqQJhtv0krMqKGRud$T743cJVPZ13Ca8nTrS68FuTgFhqnLr6NAG53YprsFY0=', NULL, 0, '张张张', '', '', '12211567353@qq.com', 0, 1, '2025-05-31 11:34:31.081250', '19988467543', '');
INSERT INTO `users` VALUES (2, 'pbkdf2_sha256$870000$Ln5fTsyLjMXixZKWNQULoO$iBXjCRHMxZANA2Vw5pzIAyuTxeNjQdzdSKMHAKWBbfM=', '2025-06-02 14:10:03.409312', 1, '张不凡', '', '', '1232133131@123.com', 1, 1, '2025-05-31 13:28:12.827855', '13113455678', '');
INSERT INTO `users` VALUES (4, 'pbkdf2_sha256$870000$ZDV2Wbys9x4dilEX3BVpVT$U6pdP8n3K7gP2LP/Di9wMJHL28WyCstl8l4xKlykexk=', NULL, 1, 'ZBF', '', '', '1232133131@123.com', 1, 1, '2025-06-04 14:28:33.821850', '13113455678', '');

-- ----------------------------
-- Table structure for users_groups
-- ----------------------------
DROP TABLE IF EXISTS `users_groups`;
CREATE TABLE `users_groups`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `customuser_id` bigint NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `users_groups_customuser_id_group_id_927de924_uniq`(`customuser_id`, `group_id`) USING BTREE,
  INDEX `users_groups_group_id_2f3517aa_fk_auth_group_id`(`group_id`) USING BTREE,
  CONSTRAINT `users_groups_customuser_id_4bd991a9_fk_users_id` FOREIGN KEY (`customuser_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `users_groups_group_id_2f3517aa_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users_groups
-- ----------------------------

-- ----------------------------
-- Table structure for users_user_permissions
-- ----------------------------
DROP TABLE IF EXISTS `users_user_permissions`;
CREATE TABLE `users_user_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `customuser_id` bigint NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `users_user_permissions_customuser_id_permission_id_2b4e4e39_uniq`(`customuser_id`, `permission_id`) USING BTREE,
  INDEX `users_user_permissio_permission_id_6d08dcd2_fk_auth_perm`(`permission_id`) USING BTREE,
  CONSTRAINT `users_user_permissio_permission_id_6d08dcd2_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `users_user_permissions_customuser_id_efdb305c_fk_users_id` FOREIGN KEY (`customuser_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users_user_permissions
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
