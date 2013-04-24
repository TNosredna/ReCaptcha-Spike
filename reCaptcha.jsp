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
    Scriptlet section                                                       z
        * Executed for each instance of the jsp/servlet
--%>
<%
    boolean requireCaptchaValidation = true;
    String theme = "white";  // blackglass, red, clean, white, custom

    if (requireCaptchaValidation) {
        request.setAttribute("theme", theme);

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
            }
        }

        request.getRequestDispatcher(getParameterAsString(request, "url")).forward(request, response);
    }
%>
<c:choose>
    <c:when test="${theme == 'custom'}">
        <script type="text/javascript">
             var RecaptchaOptions = {
                theme : 'custom',
                custom_theme_widget: 'recaptcha_widget'
             };
        </script>
        <div id="recaptcha_widget" style="display:none">
           <div id="recaptcha_image"></div>
           <div class="recaptcha_only_if_incorrect_sol" style="color:red"><fmt:message key='registration.recaptcha.label.incorrect-sol'/></div>

           <span class="recaptcha_only_if_image"><fmt:message key='registration.recaptcha.label.image'/></span>
           <span class="recaptcha_only_if_audio"><fmt:message key='registration.recaptcha.label.audio'/></span>

           <input type="text" id="recaptcha_response_field" name="recaptcha_response_field"/>

           <div class="recaptcha_refresh">
               <a href="javascript:Recaptcha.reload()"><fmt:message key='registration.recaptcha.label.get-another'/></a>
           </div>
           <div class="recaptcha_only_if_image">
               <a href="javascript:Recaptcha.switch_type('audio')"><fmt:message key='registration.recaptcha.label.get-an-audio'/></a>
           </div>
           <div class="recaptcha_only_if_audio">
               <a href="javascript:Recaptcha.switch_type('image')"><fmt:message key='registration.recaptcha.label.get-an-image'/></a>
           </div>

           <div class="recaptcha_show_help">
               <a href="javascript:Recaptcha.showhelp()"><fmt:message key='registration.recaptcha.label.show-help'/></a>
           </div>
        </div>
    </c:when>
    <c:otherwise>
        <script type="text/javascript">
            var RecaptchaOptions = {
                theme : '<%=theme%>'
            };
        </script>
        <script type="text/javascript" src="https://www.google.com/recaptcha/api/challenge?k=<%=recaptchaPublicKey%>"></script>
    </c:otherwise>
</c:choose>
 <noscript>
   <iframe src="https://www.google.com/recaptcha/api/noscript?k=<%=recaptchaPublicKey%>" height="300" width="500" frameborder="0"></iframe><br/>
   <textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
   <input type="hidden" name="recaptcha_response_field" value="manual_challenge"/>
 </noscript>