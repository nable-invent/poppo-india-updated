// String api = "https://digiblade.in/popposapi/";
// String imageUrl = api + "/images/";

String api = "https://";
String imageUrl = "http://sysorex.poppos.io";

String routes({String key = ""}) {
  String response = "";
  switch (key) {
    case "auth":
      return "/auth/obtain-auth-token/";
    case "listproduct":
      return "/products/app/api/list/?outlet=";
    case "listgroup":
      return "/products/app/api/grouplist/?outlet=";
    case "listdeliverycompany":
      return "/delivery/app/api/list/?outlet=";
    case "outlets":
      return "/outlet/app/api/list?company_code=";
    case "possession":
      return "/pos/app/api/getcurrent/?outlet=";
    case "getcustomer":
      return "/customers/app/api/?outlet=";
    case "managecustomer":
      return "/customers/app/api/?outlet=";
    case "getdriver":
      return "/customers/drivers/app/api/?outlet=";
    case "managedriver":
      return "/customers/drivers/app/api/?outlet=";
    case "getorderbyid":
      return "/orders/app/api/completed/";
    case "orderlist":
      return "/orders/app/api/completed?outlet=";
    case "editorder":
      return "/orders/app/api/edit/";
    case "createorder":
      return "/orders/app/api/create/?outlet=";
    case "logout":
      return "/auth/app/logout/";
    case "settings":
      return "/outlet/app/api/settings/?outlet=";
  }
  return response;
}
