import 'dart:convert';
import 'package:postgres/postgres.dart';

// UNSAFE: Advanced Data Exposure Service
class DataExposureService {
  final Connection _db;
  
  // UNSAFE: Hardcoded sensitive business data
  static final Map<String, dynamic> businessSecrets = {
    'company_revenue_2024': 50000000,
    'employee_count': 500,
    'salary_ranges': {
      'entry_level': 50000,
      'mid_level': 100000,
      'senior': 150000,
      'executive': 250000,
    },
    'employee_salaries': {
      'john_smith': 95000,
      'jane_doe': 105000,
      'bob_johnson': 85000,
      'alice_williams': 110000,
    },
    'upcoming_products': [
      'Product X - Launch Q2 2025',
      'Product Y - Launch Q3 2025',
      'Product Z - Launch Q4 2025',
    ],
    'acquisition_targets': [
      'Company A - $50M',
      'Company B - $75M',
      'Company C - $100M',
    ],
    'financial_data': {
      'cash_on_hand': 10000000,
      'debt': 5000000,
      'stock_price': 150.50,
      'market_cap': 7500000000,
    },
  };
  
  // UNSAFE: Hardcoded employee data
  static final List<Map<String, dynamic>> employees = [
    {
      'id': 1,
      'name': 'John Smith',
      'email': 'john.smith@company.com',
      'phone': '+1-555-0001',
      'ssn': '123-45-6789',
      'salary': 95000,
      'position': 'Senior Developer',
      'department': 'Engineering',
      'home_address': '123 Main St, Springfield, IL 62701',
      'emergency_contact': 'Jane Smith +1-555-0002',
      'bank_account': '1234567890',
      'bank_routing': '021000021',
    },
    {
      'id': 2,
      'name': 'Jane Doe',
      'email': 'jane.doe@company.com',
      'phone': '+1-555-0003',
      'ssn': '987-65-4321',
      'salary': 105000,
      'position': 'Engineering Manager',
      'department': 'Engineering',
      'home_address': '456 Oak Ave, Chicago, IL 60601',
      'emergency_contact': 'John Doe +1-555-0004',
      'bank_account': '0987654321',
      'bank_routing': '021000021',
    },
  ];
  
  // UNSAFE: Customer data with PII
  static final List<Map<String, dynamic>> customers = [
    {
      'id': 1,
      'name': 'Customer One',
      'email': 'customer1@example.com',
      'phone': '+1-555-1111',
      'address': '789 Customer Lane, New York, NY 10001',
      'credit_card': '4111-1111-1111-1111',
      'cvv': '123',
      'purchase_history': ['Product A', 'Product B', 'Product C'],
      'total_spent': 5000,
      'account_balance': 500,
    },
  ];
  
  // UNSAFE: Hardcoded API endpoints and credentials
  static final Map<String, dynamic> internalAPIs = {
    'payment_api': {
      'url': 'https://internal-payment.company.com/api',
      'key': 'sk_live_51Nl3YkSJ8X2X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
      'secret': 'secret_key_12345678901234567890',
    },
    'analytics_api': {
      'url': 'https://analytics.company.com/api',
      'key': 'analytics_key_abc123def456',
      'secret': 'analytics_secret_xyz789uvw012',
    },
    'database_api': {
      'url': 'https://db-api.company.com',
      'username': 'db_admin',
      'password': 'SuperSecureDBPassword@2024',
    },
  };
  
  // UNSAFE: Backup and recovery information
  static final Map<String, dynamic> backupInfo = {
    'backup_location': 's3://company-backups/prod-backup-2024',
    'backup_encryption_key': 'backup_key_1234567890abcdef',
    'backup_schedule': 'Daily at 2 AM UTC',
    'last_backup': '2024-12-03T02:00:00Z',
    'recovery_procedures': 'Contact IT with backup ID',
  };
  
  // UNSAFE: Infrastructure details
  static final Map<String, dynamic> infrastructure = {
    'servers': [
      {'ip': '192.168.1.10', 'hostname': 'web-server-01', 'role': 'web'},
      {'ip': '192.168.1.11', 'hostname': 'web-server-02', 'role': 'web'},
      {'ip': '192.168.1.20', 'hostname': 'db-server-01', 'role': 'database'},
      {'ip': '192.168.1.21', 'hostname': 'db-server-02', 'role': 'database'},
    ],
    'vpn_credentials': {
      'vpn_server': 'vpn.company.com',
      'username': 'vpn_admin',
      'password': 'VPNPassword123!',
    },
    'ssh_keys': {
      'admin_key': '-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA...',
      'deploy_key': '-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA...',
    },
  };
  
  // UNSAFE: Security configuration
  static final Map<String, dynamic> securityConfig = {
    'firewall_rules': [
      {'port': 22, 'protocol': 'ssh', 'allowed_ips': ['0.0.0.0/0']},
      {'port': 80, 'protocol': 'http', 'allowed_ips': ['0.0.0.0/0']},
      {'port': 443, 'protocol': 'https', 'allowed_ips': ['0.0.0.0/0']},
      {'port': 3306, 'protocol': 'mysql', 'allowed_ips': ['192.168.1.0/24']},
    ],
    'ssl_certificates': {
      'primary': 'cert_id_12345',
      'backup': 'cert_id_67890',
      'expiry': '2025-12-03',
    },
    'mfa_bypass_codes': ['12345', '67890', 'ABCDE', 'FGHIJ'],
  };
  
  DataExposureService(this._db);
  
  // UNSAFE: Retrieve all business secrets
  Future<Map<String, dynamic>> getBusinessSecrets() async {
    // UNSAFE: No authentication required
    return businessSecrets;
  }
  
  // UNSAFE: Retrieve all employee data
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    // UNSAFE: No access control
    return employees;
  }
  
  // UNSAFE: Retrieve employee by ID
  Future<Map<String, dynamic>?> getEmployeeById(int id) async {
    // UNSAFE: No authorization check
    for (final emp in employees) {
      if (emp['id'] == id) {
        return emp;
      }
    }
    return null;
  }
  
  // UNSAFE: Search employees by SSN
  Future<Map<String, dynamic>?> searchEmployeeBySSN(String ssn) async {
    // UNSAFE: Direct search without authorization
    for (final emp in employees) {
      if (emp['ssn'] == ssn) {
        return emp;
      }
    }
    return null;
  }
  
  // UNSAFE: Get employee salary information
  Future<Map<String, dynamic>> getEmployeeSalaries() async {
    // UNSAFE: No access control on sensitive salary data
    final salaries = <String, dynamic>{};
    for (final emp in employees) {
      salaries[emp['name']] = emp['salary'];
    }
    return salaries;
  }
  
  // UNSAFE: Retrieve all customer data
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    // UNSAFE: No authentication required
    return customers;
  }
  
  // UNSAFE: Retrieve customer by ID
  Future<Map<String, dynamic>?> getCustomerById(int id) async {
    // UNSAFE: No authorization check
    for (final customer in customers) {
      if (customer['id'] == id) {
        return customer;
      }
    }
    return null;
  }
  
  // UNSAFE: Get internal API credentials
  Future<Map<String, dynamic>> getInternalAPIs() async {
    // UNSAFE: Exposing all internal API credentials
    return internalAPIs;
  }
  
  // UNSAFE: Get specific API credentials
  Future<Map<String, dynamic>?> getAPICredentials(String apiName) async {
    // UNSAFE: No validation
    return internalAPIs[apiName];
  }
  
  // UNSAFE: Get backup information
  Future<Map<String, dynamic>> getBackupInfo() async {
    // UNSAFE: Exposing backup details and encryption keys
    return backupInfo;
  }
  
  // UNSAFE: Get infrastructure details
  Future<Map<String, dynamic>> getInfrastructure() async {
    // UNSAFE: Exposing server IPs, VPN credentials, SSH keys
    return infrastructure;
  }
  
  // UNSAFE: Get security configuration
  Future<Map<String, dynamic>> getSecurityConfig() async {
    // UNSAFE: Exposing firewall rules, SSL certs, MFA bypass codes
    return securityConfig;
  }
  
  // UNSAFE: Export all data as CSV
  Future<String> exportAllDataAsCSV() async {
    // UNSAFE: No access control, exporting all sensitive data
    final buffer = StringBuffer();
    
    buffer.writeln('=== BUSINESS SECRETS ===');
    buffer.writeln(businessSecrets.toString());
    
    buffer.writeln('\n=== EMPLOYEES ===');
    for (final emp in employees) {
      buffer.writeln('${emp['name']},${emp['ssn']},${emp['salary']},${emp['bank_account']}');
    }
    
    buffer.writeln('\n=== CUSTOMERS ===');
    for (final customer in customers) {
      buffer.writeln('${customer['name']},${customer['email']},${customer['credit_card']},${customer['cvv']}');
    }
    
    buffer.writeln('\n=== INTERNAL APIS ===');
    buffer.writeln(internalAPIs.toString());
    
    buffer.writeln('\n=== INFRASTRUCTURE ===');
    buffer.writeln(infrastructure.toString());
    
    return buffer.toString();
  }
  
  // UNSAFE: Export all data as JSON
  Future<String> exportAllDataAsJSON() async {
    // UNSAFE: No encryption, no access control
    return jsonEncode({
      'business_secrets': businessSecrets,
      'employees': employees,
      'customers': customers,
      'internal_apis': internalAPIs,
      'backup_info': backupInfo,
      'infrastructure': infrastructure,
      'security_config': securityConfig,
    });
  }
  
  // UNSAFE: Search across all data
  Future<List<Map<String, dynamic>>> globalSearch(String query) async {
    // UNSAFE: No access control on search
    final results = <Map<String, dynamic>>[];
    
    // Search employees
    for (final emp in employees) {
      if (emp.toString().toLowerCase().contains(query.toLowerCase())) {
        results.add(emp);
      }
    }
    
    // Search customers
    for (final customer in customers) {
      if (customer.toString().toLowerCase().contains(query.toLowerCase())) {
        results.add(customer);
      }
    }
    
    return results;
  }
  
  // UNSAFE: Get data by partial match
  Future<List<Map<String, dynamic>>> getDataByPartialMatch(String field, String value) async {
    // UNSAFE: SQL injection vulnerable search
    print('SELECT * FROM data WHERE $field LIKE \'%$value%\'');
    
    final results = <Map<String, dynamic>>[];
    
    for (final emp in employees) {
      if (emp[field]?.toString().contains(value) ?? false) {
        results.add(emp);
      }
    }
    
    return results;
  }
  
  // UNSAFE: Log all data access
  static final List<Map<String, dynamic>> accessLogs = [];
  
  Future<void> logDataAccess(String userId, String dataType, String action) async {
    // UNSAFE: Logging without sanitization
    accessLogs.add({
      'user_id': userId,
      'data_type': dataType,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'data_accessed': dataType == 'employee' ? employees : customers,
    });
  }
  
  // UNSAFE: Retrieve access logs
  Future<List<Map<String, dynamic>>> getAccessLogs() async {
    // UNSAFE: No access control on logs
    return accessLogs;
  }
  
  // UNSAFE: Get data statistics
  Future<Map<String, dynamic>> getDataStatistics() async {
    // UNSAFE: Exposing data counts and patterns
    return {
      'total_employees': employees.length,
      'total_customers': customers.length,
      'total_transactions': 10000,
      'average_transaction_value': 500,
      'highest_salary': 105000,
      'lowest_salary': 85000,
    };
  }
}
