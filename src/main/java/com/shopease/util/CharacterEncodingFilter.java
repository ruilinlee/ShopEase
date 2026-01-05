package com.shopease.util;

import javax.servlet.*;
import java.io.IOException;

/**
 * Filter to set UTF-8 encoding for all requests and responses.
 */
public class CharacterEncodingFilter implements Filter {
    private String encoding = "UTF-8";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String configEncoding = filterConfig.getInitParameter("encoding");
        if (configEncoding != null) {
            this.encoding = configEncoding;
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding(encoding);
        response.setCharacterEncoding(encoding);
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
