<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.beauty.model.User" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        // Redirect to login page if not logged in
        response.sendRedirect(request.getContextPath() + "/Auth/SignIn.jsp");
        return;
    }

    // Check if user is an admin
    String email = user.getEmail();
    if (!email.contains("Admin@gmail.com")) {
        // Redirect to client dashboard if user is not an admin
        response.sendRedirect(request.getContextPath() + "/Client/Client_Dashboard.jsp");
        return;
    }

    // Get users from request attribute
    List<User> users = (List<User>) request.getAttribute("users");

    // Get success or error messages from session
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");

    // Clear messages after retrieving them
    session.removeAttribute("message");
    session.removeAttribute("error");

    // If users is null (direct access to JSP), redirect to the servlet
    if (users == null) {
        response.sendRedirect(request.getContextPath() + "/adminUsers");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Users - Beauty Salon</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #6366f1;
            --primary-dark: #4f46e5;
        }
        .sidebar {
            transition: all 0.3s ease;
        }
        .content-area {
            transition: all 0.3s ease;
        }
    </style>
</head>
<body class="bg-gray-100">
    <!-- Header -->
    <header class="bg-white shadow-sm fixed top-0 left-0 right-0 z-10">
        <div class="flex items-center justify-between px-6 py-3">
            <!-- Logo and Name -->
            <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-indigo-100 rounded-lg flex items-center justify-center">
                    <i class="fas fa-scissors text-indigo-600"></i>
                </div>
                <h1 class="text-xl font-bold text-indigo-900">Beauty Salon Admin</h1>
            </div>

            <!-- Navigation -->
            <nav class="hidden md:flex items-center space-x-8">
                <a href="${pageContext.request.contextPath}/Admin/Admin_Dashboard.jsp" class="text-gray-600 hover:text-indigo-600">Dashboard</a>
                <a href="${pageContext.request.contextPath}/adminAppointments" class="text-gray-600 hover:text-indigo-600">Appointments</a>
                <a href="${pageContext.request.contextPath}/adminUsers" class="text-indigo-600 font-medium">Users</a>
                <a href="${pageContext.request.contextPath}/Admin/Admin_Services.jsp" class="text-gray-600 hover:text-indigo-600">Services</a>
            </nav>

            <!-- Profile Section -->
            <div class="flex items-center space-x-4">
                <div class="flex items-center space-x-2">
                    <div class="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center">
                        <i class="fas fa-user-shield text-indigo-600"></i>
                    </div>
                    <span class="hidden md:inline text-gray-700">Admin</span>
                    <a href="${pageContext.request.contextPath}/logout" class="ml-2 text-red-500 hover:text-red-700">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <div class="flex pt-16">
        <!-- Sidebar -->
        <aside class="sidebar w-64 bg-white shadow-sm fixed left-0 top-16 bottom-0 overflow-y-auto">
            <div class="p-4">
                <div class="flex items-center space-x-3 mb-6 p-3 bg-indigo-50 rounded-lg">
                    <div class="w-12 h-12 rounded-full bg-indigo-100 flex items-center justify-center">
                        <i class="fas fa-user-shield text-indigo-600 text-xl"></i>
                    </div>
                    <div>
                        <h3 class="font-medium">Admin</h3>
                        <p class="text-xs text-gray-500">System Administrator</p>
                    </div>
                </div>

                <h2 class="text-lg font-semibold text-gray-700 mb-4">Admin Menu</h2>
                <ul class="space-y-2">
                    <li>
                        <a href="${pageContext.request.contextPath}/Admin/Admin_Dashboard.jsp" class="flex items-center p-3 rounded-lg text-gray-600 hover:bg-gray-100">
                            <i class="fas fa-tachometer-alt mr-3"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/adminAppointments" class="flex items-center p-3 rounded-lg text-gray-600 hover:bg-gray-100">
                            <i class="far fa-calendar-alt mr-3"></i>
                            <span>Appointments</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/adminUsers" class="flex items-center bg-indigo-50 text-indigo-600 p-3 rounded-lg">
                            <i class="fas fa-users mr-3"></i>
                            <span>Users</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/Admin/Admin_Services.jsp" class="flex items-center p-3 rounded-lg text-gray-600 hover:bg-gray-100">
                            <i class="fas fa-cut mr-3"></i>
                            <span>Services</span>
                        </a>
                    </li>
                </ul>
            </div>
        </aside>

        <!-- Main Content Area -->
        <main class="content-area flex-1 ml-64 p-6">
            <!-- Page Header -->
            <div class="flex flex-col md:flex-row items-start md:items-center justify-between mb-6">
                <div>
                    <h1 class="text-2xl font-bold text-gray-800">User Management</h1>
                    <p class="text-gray-600">View and manage all salon users</p>
                </div>
                <div class="mt-4 md:mt-0 flex flex-wrap space-x-2">
                    <div class="relative">
                        <input type="text" id="search" placeholder="Search users..." class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
                        <button class="absolute right-2 top-2 text-gray-500">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                    <select id="role-filter" class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
                        <option value="all">All Roles</option>
                        <option value="admin">Admin Only</option>
                        <option value="client">Clients Only</option>
                    </select>
                    <select id="sort-by" class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500">
                        <option value="name-asc">Name (A-Z)</option>
                        <option value="name-desc">Name (Z-A)</option>
                        <option value="email-asc">Email (A-Z)</option>
                        <option value="email-desc">Email (Z-A)</option>
                    </select>
                    <button id="reset-filters" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 focus:outline-none">
                        <i class="fas fa-redo-alt mr-1"></i> Reset
                    </button>
                </div>
            </div>

            <!-- Messages -->
            <% if (message != null) { %>
            <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-6" role="alert">
                <p><%= message %></p>
            </div>
            <% } %>

            <% if (error != null) { %>
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6" role="alert">
                <p><%= error %></p>
            </div>
            <% } %>

            <!-- Users Table -->
            <div class="bg-white rounded-xl shadow-sm overflow-hidden mb-6">
                <div class="p-6 border-b border-gray-100">
                    <h2 class="text-xl font-semibold text-gray-800">Users (<%= users.size() %>)</h2>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Phone</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <% if (users.isEmpty()) { %>
                                <tr>
                                    <td colspan="4" class="px-6 py-4 text-center text-gray-500">No users found</td>
                                </tr>
                            <% } else { %>
                                <% for (User u : users) { %>
                                    <tr>
                                        <td class="px-6 py-4 whitespace-nowrap">
                                            <div class="flex items-center">
                                                <div class="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center mr-3">
                                                    <i class="fas fa-user text-indigo-600"></i>
                                                </div>
                                                <div class="text-sm font-medium text-gray-900"><%= u.getFirstName() %> <%= u.getLastName() %></div>
                                            </div>
                                        </td>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= u.getEmail() %></td>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= u.getPhoneNumber() != null ? u.getPhoneNumber() : "N/A" %></td>
                                        <td class="px-6 py-4 whitespace-nowrap">
                                            <% if (u.getEmail().contains("Admin@gmail.com")) { %>
                                                <span class="px-2 py-1 text-xs font-semibold rounded-full bg-purple-100 text-purple-800">Admin</span>
                                            <% } else { %>
                                                <span class="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">Client</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <!-- Footer -->
    <footer class="bg-white shadow-sm fixed bottom-0 left-0 right-0 z-10">
        <div class="flex items-center justify-between px-6 py-3">
            <!-- Copyright -->
            <p class="text-gray-600 text-sm">&copy; 2025 Beauty Salon. All rights reserved.</p>

            <!-- Navigation -->
            <nav class="hidden md:flex items-center space-x-6">
                <a href="#" class="text-gray-600 hover:text-indigo-600 text-sm">Privacy Policy</a>
                <a href="#" class="text-gray-600 hover:text-indigo-600 text-sm">Terms of Service</a>
                <a href="#" class="text-gray-600 hover:text-indigo-600 text-sm">Contact Us</a>
            </nav>
        </div>
    </footer>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('search');
            const roleFilter = document.getElementById('role-filter');
            const sortSelect = document.getElementById('sort-by');
            const tableRows = document.querySelectorAll('tbody tr');

            // Function to filter table rows
            function filterTable() {
                const searchTerm = searchInput.value.toLowerCase();
                const roleValue = roleFilter.value;

                // Update visual indicators for active filters
                updateFilterIndicators(searchTerm, roleValue);

                tableRows.forEach(row => {
                    const text = row.textContent.toLowerCase();
                    const isAdmin = row.querySelector('.bg-purple-100') !== null;
                    const isClient = row.querySelector('.bg-blue-100') !== null;

                    // Check if row matches search term
                    const matchesSearch = text.includes(searchTerm);

                    // Check if row matches role filter
                    let matchesRole = true;
                    if (roleValue === 'admin') {
                        matchesRole = isAdmin;
                    } else if (roleValue === 'client') {
                        matchesRole = isClient;
                    }

                    // Show/hide row based on filters
                    if (matchesSearch && matchesRole) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });

                // Update table header to show filtered count
                updateFilteredCount();
            }

            // Function to update visual indicators for active filters
            function updateFilterIndicators(searchTerm, roleValue) {
                // Update search input styling
                if (searchTerm) {
                    searchInput.classList.add('border-indigo-500', 'bg-indigo-50');
                } else {
                    searchInput.classList.remove('border-indigo-500', 'bg-indigo-50');
                }

                // Update role filter styling
                if (roleValue !== 'all') {
                    roleFilter.classList.add('border-indigo-500', 'bg-indigo-50');
                } else {
                    roleFilter.classList.remove('border-indigo-500', 'bg-indigo-50');
                }

                // Show/hide reset button based on if filters are active
                const resetButton = document.getElementById('reset-filters');
                if (searchTerm || roleValue !== 'all') {
                    resetButton.classList.remove('bg-gray-200', 'text-gray-700');
                    resetButton.classList.add('bg-indigo-100', 'text-indigo-700');
                } else {
                    resetButton.classList.add('bg-gray-200', 'text-gray-700');
                    resetButton.classList.remove('bg-indigo-100', 'text-indigo-700');
                }
            }

            // Function to update the filtered count in the table header
            function updateFilteredCount() {
                const visibleRows = document.querySelectorAll('tbody tr:not([style*="display: none"])').length;
                const totalRows = tableRows.length;
                const tableHeader = document.querySelector('.bg-white.rounded-xl h2');

                if (visibleRows === totalRows) {
                    tableHeader.textContent = `Users (${totalRows})`;
                } else {
                    tableHeader.textContent = `Users (${visibleRows} of ${totalRows})`;
                }
            }

            // Function to reset all filters
            function resetFilters() {
                searchInput.value = '';
                roleFilter.value = 'all';
                filterTable();
            }

            // Add event listeners
            searchInput.addEventListener('keyup', filterTable);
            roleFilter.addEventListener('change', filterTable);

            // Reset button functionality
            const resetButton = document.getElementById('reset-filters');
            resetButton.addEventListener('click', resetFilters);

            // Sort functionality
            sortSelect.addEventListener('change', function() {
                const sortValue = this.value;
                window.location.href = '${pageContext.request.contextPath}/adminUsers?sort=' + sortValue;
            });

            // Initialize table with any existing filter values
            filterTable();
        });
    </script>
</body>
</html>
