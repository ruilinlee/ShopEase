package com.shopease.servlet;

import com.shopease.entity.Address;
import com.shopease.entity.User;
import com.shopease.repository.AddressRepository;
import com.shopease.repository.UserRepository;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * User authentication controller.
 * Handles login, logout, and registration requests.
 */
@WebServlet("/user")
public class UserServlet extends HttpServlet {

    private UserRepository userRepository;
    private AddressRepository addressRepository;

    @Override
    public void init() throws ServletException {
        userRepository = UserRepository.getInstance();
        addressRepository = AddressRepository.getInstance();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("logout".equals(action)) {
            handleLogout(request, response);
        } else if ("profile".equals(action)) {
            showProfile(request, response);
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        switch (action != null ? action : "") {
            case "login":
                handleLogin(request, response);
                break;
            case "register":
                handleRegister(request, response);
                break;
            case "adminLogin":
                handleAdminLogin(request, response);
                break;
            case "updateProfile":
                handleUpdateProfile(request, response);
                break;
            case "changePassword":
                handleChangePassword(request, response);
                break;
            case "addAddress":
                handleAddAddress(request, response);
                break;
            case "deleteAddress":
                handleDeleteAddress(request, response);
                break;
            case "setDefaultAddress":
                handleSetDefaultAddress(request, response);
                break;
            default:
                response.sendRedirect("login.jsp");
        }
    }

    /** Validates credentials and creates session with role-based redirect. */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String loginRole = request.getParameter("loginRole");

        // Default to customer if not specified
        if (loginRole == null || loginRole.trim().isEmpty()) {
            loginRole = "customer";
        }

        if (username == null || password == null ||
                username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        final String selectedRole = loginRole.trim().toLowerCase();

        userRepository.authenticate(username.trim(), password)
                .ifPresentOrElse(
                        user -> {
                            try {
                                // Check if role matches
                                String userRole = user.getRole();

                                if ("admin".equals(selectedRole)) {
                                    // Admin login attempt - verify user is actually admin
                                    if (!"admin".equals(userRole)) {
                                        request.setAttribute("error",
                                                "Invalid admin credentials. This account is not an admin.");
                                        request.getRequestDispatcher("/login.jsp").forward(request, response);
                                        return;
                                    }
                                    // Admin login successful
                                    createSession(request, user);
                                    response.sendRedirect("admin.jsp");
                                } else {
                                    // Customer login attempt - verify user is not admin
                                    if ("admin".equals(userRole)) {
                                        request.setAttribute("error",
                                                "Admin accounts cannot login as customer. Please select Admin role.");
                                        request.getRequestDispatcher("/login.jsp").forward(request, response);
                                        return;
                                    }
                                    // Customer login successful
                                    createSession(request, user);
                                    response.sendRedirect("products");
                                }
                            } catch (ServletException | IOException e) {
                                e.printStackTrace();
                            }
                        },
                        () -> {
                            try {
                                request.setAttribute("error", "Invalid username or password");
                                request.getRequestDispatcher("/login.jsp").forward(request, response);
                            } catch (ServletException | IOException e) {
                                e.printStackTrace();
                            }
                        });
    }

    /** Admin login with role verification. */
    private void handleAdminLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null ||
                username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required");
            request.getRequestDispatcher("/admin_login.jsp").forward(request, response);
            return;
        }

        userRepository.authenticate(username.trim(), password)
                .filter(User::isAdmin)
                .ifPresentOrElse(
                        user -> {
                            try {
                                createSession(request, user);
                                response.sendRedirect("admin.jsp");
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        },
                        () -> {
                            try {
                                request.setAttribute("error", "Invalid admin credentials");
                                request.getRequestDispatcher("/admin_login.jsp").forward(request, response);
                            } catch (ServletException | IOException e) {
                                e.printStackTrace();
                            }
                        });
    }

    /** Processes registration with validation. */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validation
        if (username == null || email == null || password == null ||
                username.trim().isEmpty() || email.trim().isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (userRepository.usernameExists(username.trim())) {
            request.setAttribute("error", "Username already taken");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (userRepository.emailExists(email.trim())) {
            request.setAttribute("error", "Email already registered");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Create new user
        User newUser = new User(username.trim(), password, email.trim());
        userRepository.save(newUser);

        // Auto-login after registration
        createSession(request, newUser);
        response.sendRedirect("products");
    }

    /** Invalidates session and redirects to home. */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect("index.jsp");
    }

    /** Initializes session attributes for authenticated user. */
    private void createSession(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("role", user.getRole());
        session.setAttribute("email", user.getEmail());
        session.setAttribute("phone", user.getPhone());
        session.setAttribute("fullName", user.getFullName());
    }

    /** Shows user profile page. */
    private void showProfile(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        List<Address> addresses = addressRepository.findByUserId(userId);
        request.setAttribute("addresses", addresses);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    /** Handles profile information update. */
    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        userRepository.findById(userId).ifPresent(user -> {
            user.setFullName(fullName != null ? fullName.trim() : null);
            user.setEmail(email != null ? email.trim() : user.getEmail());
            user.setPhone(phone != null ? phone.trim() : null);
            userRepository.save(user);

            // Update session
            session.setAttribute("email", user.getEmail());
            session.setAttribute("phone", user.getPhone());
            session.setAttribute("fullName", user.getFullName());
        });

        request.setAttribute("success", "Profile updated successfully");
        List<Address> addresses = addressRepository.findByUserId(userId);
        request.setAttribute("addresses", addresses);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    /** Handles password change. */
    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        List<Address> addresses = addressRepository.findByUserId(userId);
        request.setAttribute("addresses", addresses);

        if (newPassword == null || newPassword.length() < 6) {
            request.setAttribute("error", "New password must be at least 6 characters");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New passwords do not match");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        User user = userRepository.findById(userId).orElse(null);
        if (user == null || !user.getPassword().equals(currentPassword)) {
            request.setAttribute("error", "Current password is incorrect");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        user.setPassword(newPassword);
        userRepository.save(user);

        request.setAttribute("success", "Password changed successfully");
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    /** Handles adding a new address. */
    private void handleAddAddress(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");

        Address address = new Address();
        address.setUserId(userId);
        address.setRecipientName(request.getParameter("recipientName"));
        address.setPhoneNumber(request.getParameter("phoneNumber"));
        address.setAddressLine1(request.getParameter("addressLine1"));
        address.setAddressLine2(request.getParameter("addressLine2"));
        address.setPostalCode(request.getParameter("postalCode"));
        address.setCity(request.getParameter("city"));
        address.setState(request.getParameter("state"));

        // Check if should set as default
        boolean setDefault = "on".equals(request.getParameter("setDefault"));
        boolean isFirstAddress = addressRepository.countByUserId(userId) == 0;

        // If this is first address or setDefault is checked, mark it as default
        if (isFirstAddress || setDefault) {
            address.setDefault(true);
        }

        // Save the address first
        addressRepository.save(address);

        // If setting as default, update other addresses to non-default
        if (address.isDefault()) {
            addressRepository.setAsDefault(address.getId(), userId);
        }

        // Check if should return to checkout
        boolean returnToCheckout = "true".equals(request.getParameter("returnToCheckout"));

        if (returnToCheckout) {
            response.sendRedirect("orders?action=checkout");
        } else {
            request.setAttribute("success", "Address added successfully");
            List<Address> addresses = addressRepository.findByUserId(userId);
            request.setAttribute("addresses", addresses);
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
        }
    }

    /** Handles deleting an address. */
    private void handleDeleteAddress(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String addressId = request.getParameter("addressId");

        if (addressId != null) {
            // Verify ownership before deleting
            addressRepository.findById(addressId)
                    .filter(addr -> userId.equals(addr.getUserId()))
                    .ifPresent(addr -> addressRepository.delete(addressId));
        }

        request.setAttribute("success", "Address deleted");
        List<Address> addresses = addressRepository.findByUserId(userId);
        request.setAttribute("addresses", addresses);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    /** Handles setting an address as default. */
    private void handleSetDefaultAddress(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String addressId = request.getParameter("addressId");

        if (addressId != null) {
            addressRepository.setAsDefault(addressId, userId);
        }

        request.setAttribute("success", "Default address updated");
        List<Address> addresses = addressRepository.findByUserId(userId);
        request.setAttribute("addresses", addresses);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }
}
