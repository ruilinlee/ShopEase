package com.shopease.servlet;

import com.shopease.entity.Order;
import com.shopease.entity.Product;
import com.shopease.entity.Review;
import com.shopease.entity.User;
import com.shopease.repository.OrderRepository;
import com.shopease.repository.ProductRepository;
import com.shopease.repository.ReviewRepository;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Handles product operations: list, search, details, publish.
 */
@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    private ProductRepository productRepository;
    private OrderRepository orderRepository;
    private static final int MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    private static final String UPLOAD_DIR = "uploads";

    @Override
    public void init() throws ServletException {
        productRepository = ProductRepository.getInstance();
        orderRepository = OrderRepository.getInstance();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "details":
                showDetails(request, response);
                break;
            case "publish":
                showPublishForm(request, response);
                break;
            case "myListings":
                showMyListings(request, response);
                break;
            case "mySales":
                showMySales(request, response);
                break;
            case "delete":
                deleteListing(request, response);
                break;
            default:
                listProducts(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("publish".equals(action) || ServletFileUpload.isMultipartContent(request)) {
            handlePublish(request, response);
        } else {
            response.sendRedirect("products");
        }
    }

    /**
     * Lists all approved products with optional filtering.
     */
    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String category = request.getParameter("category");
        String search = request.getParameter("search");

        List<Product> products;

        if (search != null && !search.trim().isEmpty()) {
            products = productRepository.search(search.trim());
            request.setAttribute("searchQuery", search.trim());
        } else if (category != null && !category.isEmpty() && !"all".equalsIgnoreCase(category)) {
            products = productRepository.findByCategory(category);
            request.setAttribute("selectedCategory", category);
        } else {
            products = productRepository.findApproved();
        }

        request.setAttribute("products", products);
        request.setAttribute("categories", getCategories());
        request.getRequestDispatcher("/shop.jsp").forward(request, response);
    }

    /**
     * Shows product details.
     */
    private void showDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productId = request.getParameter("id");

        if (productId == null || productId.isEmpty()) {
            response.sendRedirect("products");
            return;
        }

        productRepository.findById(productId).ifPresentOrElse(
                product -> {
                    try {
                        request.setAttribute("product", product);

                        // Add reviews data
                        ReviewRepository reviewRepo = ReviewRepository.getInstance();
                        List<Review> reviews = reviewRepo.findByProductId(productId);
                        request.setAttribute("reviews", reviews);
                        request.setAttribute("avgRating", reviewRepo.getAverageRating(productId));
                        request.setAttribute("reviewCount", reviews.size());

                        // Check if current user has reviewed
                        String userId = (String) request.getSession().getAttribute("userId");
                        if (userId != null) {
                            boolean hasReviewed = reviewRepo.hasUserReviewedProduct(userId, productId);
                            request.setAttribute("hasUserReviewed", hasReviewed);
                        }

                        request.getRequestDispatcher("/details.jsp").forward(request, response);
                    } catch (ServletException | IOException e) {
                        e.printStackTrace();
                    }
                },
                () -> {
                    try {
                        response.sendRedirect("products");
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                });
    }

    /**
     * Shows the publish form (requires login).
     */
    private void showPublishForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Check if editing existing product
        String editId = request.getParameter("edit");
        if (editId != null && !editId.isEmpty()) {
            productRepository.findById(editId).ifPresent(product -> {
                request.setAttribute("editProduct", product);
            });
        }

        request.setAttribute("categories", getCategories());
        request.getRequestDispatcher("/publish.jsp").forward(request, response);
    }

    /**
     * Shows current user's listings.
     */
    private void showMyListings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) request.getSession().getAttribute("userId");
        List<Product> products = productRepository.findBySellerId(userId);

        request.setAttribute("products", products);
        request.setAttribute("isMyListings", true);
        request.getRequestDispatcher("/my_listings.jsp").forward(request, response);
    }

    /**
     * Deletes a product listing owned by the current user.
     */
    private void deleteListing(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String productId = request.getParameter("id");
        String userId = (String) request.getSession().getAttribute("userId");

        if (productId != null && userId != null) {
            productRepository.findById(productId)
                    .filter(product -> userId.equals(product.getSellerId()))
                    .ifPresent(product -> productRepository.delete(productId));
        }

        response.sendRedirect("products?action=myListings");
    }

    /**
     * Shows seller's sales/orders containing their products.
     */
    private void showMySales(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = (String) request.getSession().getAttribute("userId");
        List<Product> myProducts = productRepository.findBySellerId(userId);
        List<String> myProductIds = myProducts.stream()
                .map(Product::getId)
                .collect(Collectors.toList());

        // Find orders containing seller's products
        List<Order> allOrders = orderRepository.findAll();
        List<Order> mySales = allOrders.stream()
                .filter(order -> order.getItems().stream()
                        .anyMatch(item -> myProductIds.contains(item.getProductId())))
                .collect(Collectors.toList());

        request.setAttribute("sales", mySales);
        request.getRequestDispatcher("/my_sales.jsp").forward(request, response);
    }

    /**
     * Handles product publishing with image upload.
     */
    private void handlePublish(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");

        try {
            // Configure file upload
            DiskFileItemFactory factory = new DiskFileItemFactory();
            factory.setSizeThreshold(MAX_FILE_SIZE);

            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setFileSizeMax(MAX_FILE_SIZE);

            List<FileItem> formItems = upload.parseRequest(request);

            String action = "";
            String productId = "";
            String name = "";
            String description = "";
            String category = "";
            String status = "available";
            double price = 0;
            int stock = 1;
            String imageUrl = "";
            String existingImage = "";
            String detailedAddress = "";
            String shippingState = "";

            // Process form fields
            for (FileItem item : formItems) {
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String fieldValue = item.getString("UTF-8");

                    switch (fieldName) {
                        case "action":
                            action = fieldValue;
                            break;
                        case "productId":
                            productId = fieldValue;
                            break;
                        case "name":
                            name = fieldValue;
                            break;
                        case "description":
                            description = fieldValue;
                            break;
                        case "category":
                            category = fieldValue;
                            break;
                        case "status":
                            status = fieldValue;
                            break;
                        case "price":
                            try {
                                price = Double.parseDouble(fieldValue);
                            } catch (NumberFormatException e) {
                                price = 0;
                            }
                            break;
                        case "stock":
                            try {
                                stock = Integer.parseInt(fieldValue);
                            } catch (NumberFormatException e) {
                                stock = 1;
                            }
                            break;
                        case "existingImage":
                            existingImage = fieldValue;
                            break;
                        case "detailedAddress":
                            detailedAddress = fieldValue;
                            break;
                        case "shippingState":
                            shippingState = fieldValue;
                            break;
                    }
                } else {
                    // Handle file upload
                    if (item.getSize() > 0) {
                        String fileName = item.getName();
                        if (fileName != null && !fileName.isEmpty()) {
                            // Generate unique filename
                            String extension = getFileExtension(fileName);
                            String newFileName = UUID.randomUUID().toString() + extension;

                            // Get upload directory path - use products subfolder
                            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR
                                    + File.separator + "products";
                            File uploadDir = new File(uploadPath);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }

                            // Save file
                            String filePath = uploadPath + File.separator + newFileName;
                            item.write(new File(filePath));

                            imageUrl = UPLOAD_DIR + "/products/" + newFileName;
                        }
                    }
                }
            }

            // Use existing image if no new image uploaded
            if (imageUrl.isEmpty() && !existingImage.isEmpty()) {
                imageUrl = existingImage;
            }

            // Validate required fields
            if (name.isEmpty() || category.isEmpty() || price <= 0) {
                request.setAttribute("error", "Name, category and price are required");
                request.setAttribute("categories", getCategories());
                request.getRequestDispatcher("/publish.jsp").forward(request, response);
                return;
            }

            // Enhanced validation
            if (name.length() < 2 || name.length() > 100) {
                request.setAttribute("error", "Name must be 2-100 characters");
                request.setAttribute("categories", getCategories());
                request.getRequestDispatcher("/publish.jsp").forward(request, response);
                return;
            }

            if (price < 0.01 || price > 999999.99) {
                request.setAttribute("error", "Price must be between $0.01 and $999,999.99");
                request.setAttribute("categories", getCategories());
                request.getRequestDispatcher("/publish.jsp").forward(request, response);
                return;
            }

            if (stock < 1 || stock > 9999) {
                request.setAttribute("error", "Stock must be between 1 and 9,999");
                request.setAttribute("categories", getCategories());
                request.getRequestDispatcher("/publish.jsp").forward(request, response);
                return;
            }

            if (description.length() > 2000) {
                request.setAttribute("error", "Description cannot exceed 2,000 characters");
                request.setAttribute("categories", getCategories());
                request.getRequestDispatcher("/publish.jsp").forward(request, response);
                return;
            }

            // Validate detailed address length
            if (detailedAddress.length() > 500) {
                request.setAttribute("error", "Detailed address cannot exceed 500 characters");
                request.setAttribute("categories", getCategories());
                request.getRequestDispatcher("/publish.jsp").forward(request, response);
                return;
            }

            // Check if updating existing product or creating new
            if ("update".equals(action) && !productId.isEmpty()) {
                // Update existing product
                // Update existing product
                java.util.Optional<Product> existingProductOpt = productRepository.findById(productId);
                if (existingProductOpt.isPresent()) {
                    Product product = existingProductOpt.get();
                    product.setName(name);
                    product.setDescription(description);
                    product.setPrice(price);
                    product.setCategory(category);
                    product.setStatus(status);
                    product.setStock(stock);
                    product.setDetailedAddress(detailedAddress);
                    product.setShippingState(shippingState);
                    if (!imageUrl.isEmpty()) {
                        product.setImageUrl(imageUrl);
                    }
                    productRepository.save(product);
                }
                response.sendRedirect("products?success=updated");
            } else {
                // Create new product
                Product product = new Product(name, description, price, category, imageUrl, userId);
                product.setSellerName(username);
                product.setStatus("available"); // Sale status: available for purchase once approved
                product.setApprovalStatus("pending"); // Requires admin approval
                product.setStock(stock);
                product.setDetailedAddress(detailedAddress);
                product.setShippingState(shippingState);

                productRepository.save(product);

                response.sendRedirect("products?success=published");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to publish product: " + e.getMessage());
            request.setAttribute("categories", getCategories());
            request.getRequestDispatcher("/publish.jsp").forward(request, response);
        }
    }

    /**
     * Gets available product categories.
     */
    private String[] getCategories() {
        return new String[] { "electronics", "books", "clothing", "sports", "furniture", "others" };
    }

    /**
     * Checks if user is logged in.
     */
    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("userId") != null;
    }

    /**
     * Gets file extension from filename.
     */
    private String getFileExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.');
        if (lastDot > 0) {
            return fileName.substring(lastDot).toLowerCase();
        }
        return ".jpg";
    }
}
