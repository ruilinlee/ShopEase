# ShopEase

A lightweight Java EE e-commerce platform for campus second-hand trading.

## Overview

ShopEase provides a peer-to-peer marketplace where students can buy and sell used items within their campus community. The system supports user authentication, product listing, shopping cart management, order processing, and Malaysian payment methods.

### Core Features

- **User Management** - Registration, authentication, profile management, address book
- **Product Catalog** - Browse, search, filter by category, product reviews
- **Shopping Cart** - Add/remove items, quantity management, selective checkout
- **Order Processing** - Checkout workflow, order history, refund requests
- **Payment Methods** - Malaysian banks (Maybank, CIMB, Public Bank), e-wallets (Touch 'n Go, GrabPay), Credit/Debit cards
- **Seller Dashboard** - My listings, sales management, refund approval
- **Admin Console** - User management, product moderation, analytics

## Quick Start

### Prerequisites

- JDK 11+
- Apache Tomcat 9.x
- Gradle (wrapper included)

### Build & Deploy

```powershell
# Complete redeployment (recommended - stops, cleans, builds, deploys, starts)
.\scripts\redeploy.ps1

# Or use individual scripts:
.\scripts\deploy.ps1   # Build and deploy WAR
.\scripts\start.ps1    # Start Tomcat server
.\scripts\stop.ps1     # Stop Tomcat server
```

Access the application at `http://localhost:8080/shopease`

### Default Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | admin123 |
| User | john_doe | pass123 |

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│              JSP + Bootstrap 5 + JavaScript             │
├─────────────────────────────────────────────────────────┤
│                    Controller Layer                     │
│                  Java Servlets (MVC)                    │
├─────────────────────────────────────────────────────────┤
│                    Repository Layer                     │
│             JSON-based File Persistence                 │
│            (Thread-safe with ReadWriteLock)             │
└─────────────────────────────────────────────────────────┘
```

### Project Structure

```
├── src/main/
│   ├── java/com/shopease/
│   │   ├── entity/         # Domain models (User, Product, Order, Address, Review)
│   │   ├── repository/     # Data access layer (JSON file persistence)
│   │   ├── servlet/        # HTTP request handlers (MVC controllers)
│   │   └── util/           # Utilities, filters, validation
│   └── webapp/
│       ├── WEB-INF/        # Deployment descriptors
│       ├── payment-icons/  # Payment method SVG icons
│       ├── uploads/        # User-uploaded product images
│       └── *.jsp           # View templates
├── data/                   # JSON data store (runtime)
├── scripts/                # PowerShell deployment scripts
└── build.gradle            # Gradle build configuration
```

## Technology Stack

| Component | Version |
|-----------|---------|
| Java | 11+ |
| Servlet API | 4.0 |
| JSP/JSTL | 2.3/1.2 |
| Bootstrap | 5.3 |
| Gson | 2.10 |
| Tomcat | 9.x |

## Development

### Adding New Features

1. Create entity class in `entity/` package
2. Implement repository in `repository/` package
3. Add servlet handler in `servlet/` package
4. Create JSP view in `webapp/`

### Data Storage

Application data is stored in JSON files under `data/`:
- `users.json` - User accounts and profiles
- `products.json` - Product listings
- `carts.json` - Shopping cart data
- `orders.json` - Order records with payment and shipping info
- `addresses.json` - User shipping addresses
- `reviews.json` - Product reviews and ratings

### Configuration

Web configuration is defined in `src/main/webapp/WEB-INF/web.xml`:
- Servlet mappings
- Filter configuration
- Session timeout settings
- Error page handlers

## Deployment

### Production Deployment

1. Build release WAR: `.\gradlew war`
2. Copy `build/libs/shopease-*.war` to Tomcat webapps directory
3. Configure Tomcat for production (adjust `server.xml`)
4. Start Tomcat service

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| CATALINA_HOME | Tomcat installation path | (auto-detected) |
| JAVA_HOME | JDK installation path | (required) |

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m "Add feature"`
4. Push branch: `git push origin feature/your-feature`
5. Submit pull request

### Code Style

- Follow Google Java Style Guide
- Use meaningful variable and method names
- Keep methods focused and concise
- Add Javadoc for public APIs

## License

Copyright 2024. All rights reserved.
