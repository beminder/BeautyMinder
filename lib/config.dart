class Config {
  static const String appName = "BeautyMinder";

  //Config
  // static const apiURL = "beautyminder.site"; // Web
  static const apiURL = "ec2-43-202-92-163.ap-northeast-2.compute.amazonaws.com:8080";


  static const loginAPI = "/login";
  static const deleteAPI = "/user/delete";
  static const userProfileAPI = "/user/me";
  static const editUserInfo = "/user/update";
  static const editProfileImg = "user/upload";
  static const getUserReview = "/user/reviews";

  static const getCosmeticInfobyIdAPI ='';
  static const logoutAPI = "/user/logout";

  static const certificateAdminAPI = "/admin/hello";

  //password
  static const updatePassword = "/user/update-password";

  //signup
  static const registerAPI = "/user/signup";
  static const emailVerifyRequestAPI = "/user/email-verification/request"; //이메일 인증
  static const emailTokenRequestAPI = "/user/email-verification/verify"; //이메일 토큰 확인

  //forget password
  static const requestByEmail = "/user/forgot-password";
  static const requestByPhoneNum = "/user/sms/send/";

  //password
  static const changePassword = "/user/change-password";
  static const requestResetPassword = "/user/forgot-password";

  //home
  static const getUserInfo = "user/me/";

  // Todo
  static const Todo = "/todo/";
  static const todoAPI = "/todo/all";
  static const todoAddAPI = "/todo/create";
  static const todoDelAPI = "/todo/delete/";
  static const todoUpdateAPI = "/todo/update/";

  //Baumann
  static const baumannSurveyAPI = "/baumann/survey";
  static const baumannTestAPI = "/baumann/test";
  static const baumannHistoryAPI = "/baumann/history";
  static const baumannDeleteAPI = "/baumann/delete/";

  //rank
  static const keywordRankAPI = "/redis/top/keywords";
  static const productRankAPI = "/redis/top/cosmetics";

  //search
  static const homeSearchKeywordAPI = "/search";
  static const searchReviewbyContentAPI = "/search/review";
  static const searchCosmeticsbyKeyword = "/search/keyword";
  static const searchCosmeticsbyName = "/search/cosmetic";
  static const searchCosmeticsbyCategory = "/search/category";
  static const getSearchHistoryAPI = "/user/search-history";

  //gpt review
  static const getGPTReviewAPI = "gpt/review";

  // Cosmetic
  static const CosmeticAPI = "/cosmetic";

  // Recommend
  static const RecommendAPI = "/recommend";

  //review
  static const AllReviewAPI = "/review";
  static const getReviewAPI = "/review/";
  static const ReviewImageAPI = "/review/image";

  //expiry
  static const createCosmeticExpiryAPI = "/expiry/create";
  static const getAllExpiryByUserIdAPI = "/expiry/user/";
  static const getExpiryByUserIdandExpiryIdAPI = "/expiry/";
  static const getAllExpiriesAPI = "/expiry";

  //chat
  static const chatAPI = '/chat/list';
  static const chatLoginAPI = '/chat/login';

  //OCR
  static const ocrAPI = "/vision/ocr";

  //favorites
  static const uploadFavoritesAPI = "/user/favorites/";
}
