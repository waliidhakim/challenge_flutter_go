import 'dart:html' as html;
import 'dart:js' as js;

void setCookie(String name, String value, int days) {
  var expires = "";
  if (days > 0) {
    var date = DateTime.now().add(Duration(days: days));
    expires = "; expires=${date.toUtc().toIso8601String()}";
  }
  js.context
      .callMethod('eval', ['document.cookie = "$name=$value$expires; path=/"']);
}

String? getCookie(String name) {
  String cookies = html.document.cookie!; // Get all cookies
  List<String> cookieList =
      cookies.split('; '); // Split the cookies string into individual cookies
  for (var cookie in cookieList) {
    if (cookie.startsWith(name + '=')) {
      return cookie
          .substring(name.length + 1); // Return the value part of the cookie
    }
  }
  return null; // Return null if the cookie is not found
}

void setAuthorizationCookie(String token) {
  html.document.cookie = 'Authorization=$token; Path=/; Secure; SameSite=None';
}
