<%@ page import="net.tanesha.recaptcha.*" %>

<%--
    Declaration section
        * Shared by all instances of the jsp/servlet
        * Executed/initialized when the jsp/servlet is first instantiated
        * Never changes after initial execution
--%>
<%!
    private final boolean isTestMode = true;
    private final String captchaBypassCode = "132BYPASSCAPTCHA089";
    private final String recaptchaPrivateKey = "6LdcHbwSAAAAABCc60KoqcrBfH5oGY4IAadSVoei";
    private final String recaptchaPublicKey = "6LdcHbwSAAAAABmejavsLr6B1EewGfT7jxEqvocI";

    private static String getParameterAsString(HttpServletRequest request, String parameterName) {
        return getParameterAsString(request, parameterName, "");
    }

    private static String getParameterAsString(HttpServletRequest request, String parameterName, String defaultValue) {
        if (request.getSession().getAttribute(parameterName) != null) {
            return request.getSession().getAttribute(parameterName).toString();
        }
        if (request.getAttribute(parameterName) != null) {
            return request.getAttribute(parameterName).toString();
        }
        if (request.getParameter(parameterName) != null) {
            return request.getParameter(parameterName);
        }
        return defaultValue;
    }

    private static int getParameterAsInteger(HttpServletRequest request, String parameterName, int defaultValue) {
        if (request.getSession().getAttribute(parameterName) != null) {
            return Integer.parseInt(request.getSession().getAttribute(parameterName).toString());
        }
        if (request.getAttribute(parameterName) != null) {
            return Integer.parseInt(request.getAttribute(parameterName).toString());
        }
        if (request.getParameter(parameterName) != null) {
            return Integer.parseInt(request.getParameter(parameterName));
        }
        return defaultValue;
    }
%>
<%--
    Declaration section
        * Executed for each instance of the jsp/servlet
--%>
<%
    String formSubmitUrl = getParameterAsString(request, "url", "http://google.com");
    boolean requireCaptchaValidation = true;
    String theme = "white";  // blackglass, red, clean, white, custom
%>
<%--

    if (requireCaptchaValidation) {
        if (request.getMethod().equals("GET")) { // Equivalent to a servlet doGet() method, except no need to call RequestDispatcher#forward().
        }
        if (request.getMethod().equals("POST")) { // Equivalent to a servlet doPost() method, except no need to call RequestDispatcher#forward().
            String remoteAddr = request.getRemoteAddr();
            ReCaptchaImpl reCaptcha = new ReCaptchaImpl();
            reCaptcha.setPrivateKey(recaptchaPrivateKey);

            String challenge = request.getParameter("recaptcha_challenge_field");
            if (challenge == null) {
                //logger.error("Captcha service is unavailable.  Disabling Captcha requirement for this request.");
                return;
            }
            String captchaResponse = request.getParameter("recaptcha_response_field");
            if (isTestMode && captchaResponse != null && captchaResponse.length() > 0 && captchaResponse.equalsIgnoreCase(captchaBypassCode)) {
                //logger.info("Captcha service bypass code provided.  Disabling Captcha requirement for this request.");
                return;
            }

            ReCaptchaResponse reCaptchaResponse;
            try {
                reCaptchaResponse = reCaptcha.checkAnswer(remoteAddr, challenge, captchaResponse);
            } catch (ReCaptchaException e) {
                if (captchaResponse != null && captchaResponse.length() > 0) {
                    ///logger.warn("Captcha service is unavailable, likely due to web-server firewall rules. Disabling Captcha requirement for this request and returning a 'valid' for user's response.");
                    return;
                } else {
                    //logger.warn("Captcha service is unavailable, likely due to web-server firewall rules. Disabling Captcha requirement for this request and returning an 'invalid' for user's response since the user didn't provide one.");
                    //getFormErrors(request).reject("error.registration.captcha-value-does-not-match");
                    return;
                }
            } catch (Exception e) {
                if (captchaResponse != null && captchaResponse.length() > 0) {
                    //logger.warn("Captcha service is unavailable, likely due to web-server firewall rules. Disabling Captcha requirement for this request and returning a 'valid' for user's response.");
                    return;
                } else {
                    //logger.warn("Captcha service is unavailable, likely due to web-server firewall rules. Disabling Captcha requirement for this request and returning an 'invalid' for user's response since the user didn't provide one.");
                    //getFormErrors(request).reject("error.registration.captcha-value-does-not-match");
                    return;
                }
            }

            if (!reCaptchaResponse.isValid()) {
                request.getRequestDispatcher(request.getRequestURL().toString()).forward(request, response);
            } else {
                response.sendRedirect(formSubmitUrl);
            }
        }
    }
--%>