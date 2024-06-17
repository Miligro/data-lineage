CREATE TABLE customers (
  id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL,
  city VARCHAR(50) NOT NULL,
  state VARCHAR(2) NOT NULL,
  zip_code VARCHAR(10) NOT NULL
);

CREATE TABLE accounts (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  account_type VARCHAR(20) NOT NULL,
  balance DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE transactions (
  id INT PRIMARY KEY,
  account_id INT NOT NULL,
  transaction_date DATE NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  type VARCHAR(10) NOT NULL,
  FOREIGN KEY (account_id) REFERENCES accounts(id)
);

CREATE TABLE invoices (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  invoice_date DATE NOT NULL,
  total DECIMAL(15, 2) NOT NULL,
  paid INT DEFAULT 0,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE payments (
  id INT PRIMARY KEY,
  invoice_id INT NOT NULL,
  payment_date DATE NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (invoice_id) REFERENCES invoices(id)
);

CREATE TABLE employees (
  id INT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL
);

CREATE TABLE departments (
  id INT PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE salaries (
  id INT PRIMARY KEY,
  employee_id INT NOT NULL,
  salary DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE budget_categories (
  id INT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL
);

CREATE TABLE budget_items (
  id INT PRIMARY KEY,
  category_id INT NOT NULL,
  item_name VARCHAR(100) NOT NULL,
  budget DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (category_id) REFERENCES budget_categories(id)
);

CREATE TABLE financial_reports (
  id INT PRIMARY KEY,
  report_date DATE NOT NULL,
  total_income DECIMAL(15, 2) NOT NULL,
  total_expense DECIMAL(15, 2) NOT NULL,
  profit DECIMAL(15, 2) NOT NULL
);

CREATE TABLE credit_cards (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  card_number VARCHAR(20) NOT NULL,
  expiration_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE credit_card_transactions (
  id INT PRIMARY KEY,
  credit_card_id INT NOT NULL,
  transaction_date DATE NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  type VARCHAR(10) NOT NULL,
  FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id)
);

CREATE TABLE loans (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  loan_amount DECIMAL(15, 2) NOT NULL,
  interest_rate DECIMAL(5, 2) NOT NULL,
  loan_term INT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE loan_payments (
  id INT PRIMARY KEY,
  loan_id INT NOT NULL,
  payment_date DATE NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (loan_id) REFERENCES loans(id)
);

CREATE TABLE investments (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  investment_type VARCHAR(20) NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE investment_transactions (
  id INT PRIMARY KEY,
  investment_id INT NOT NULL,
  transaction_date DATE NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  type VARCHAR(10) NOT NULL,
  FOREIGN KEY (investment_id) REFERENCES investments(id)
);

CREATE TABLE insurance_policies (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  policy_type VARCHAR(20) NOT NULL,
  premium DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE insurance_claims (
  id INT PRIMARY KEY,
  policy_id INT NOT NULL,
  claim_date DATE NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  type VARCHAR(10) NOT NULL,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id)
);

CREATE TABLE tax_returns (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  filing_status VARCHAR(20) NOT NULL,
  total_income DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE tax_payments (
  id INT PRIMARY KEY,
  return_id INT NOT NULL,
  payment_date DATE NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (return_id) REFERENCES tax_returns(id)
);

CREATE TABLE vendor_invoices (
  id INT PRIMARY KEY,
  invoice_number VARCHAR(20) NOT NULL,
  invoice_date DATE NOT NULL,
  total DECIMAL(15, 2) NOT NULL,
  paid INT DEFAULT 0
);

CREATE TABLE vendor_payments (
  id INT PRIMARY KEY,
  invoice_id INT NOT NULL,
  payment_date DATE NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (invoice_id) REFERENCES vendor_invoices(id)
);

CREATE TABLE employee_expenses (
  id INT PRIMARY KEY,
  employee_id INT NOT NULL,
  expense_type VARCHAR(20) NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE department_allocations (
  id INT PRIMARY KEY,
  department_id INT NOT NULL,
  allocation_amount DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE financial_goals (
  id INT PRIMARY KEY,
  goal_type VARCHAR(20) NOT NULL,
  target_date DATE NOT NULL,
  target_amount DECIMAL(15, 2) NOT NULL
);

CREATE TABLE goal_tracker (
  id INT PRIMARY KEY,
  goal_id INT NOT NULL,
  tracked_date DATE NOT NULL,
  progress DECIMAL(5, 2) NOT NULL,
  FOREIGN KEY (goal_id) REFERENCES financial_goals(id)
);

CREATE TABLE investment_opportunities (
  id INT PRIMARY KEY,
  customer_id INT,
  opportunity_name VARCHAR(50) NOT NULL,
  investment_type VARCHAR(20) NOT NULL,
  expected_return DECIMAL(5, 2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE market_analysis (
  id INT PRIMARY KEY,
  analysis_date DATE NOT NULL,
  market_trend VARCHAR(20) NOT NULL,
  investment_opportunity_id INT,
  FOREIGN KEY (investment_opportunity_id) REFERENCES investment_opportunities(id)
);

CREATE TABLE portfolio_recommendations (
  id INT PRIMARY KEY,
  recommendation_date DATE NOT NULL,
  recommended_investment DECIMAL(15, 2) NOT NULL,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE financial_planning (
  id INT PRIMARY KEY,
  planning_date DATE NOT NULL,
  financial_goal DECIMAL(15, 2) NOT NULL,
  employee_id INT,
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE tax_filing_status (
  id INT PRIMARY KEY,
  filing_status VARCHAR(20) NOT NULL,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE insurance_coverage (
  id INT PRIMARY KEY,
  coverage_type VARCHAR(20) NOT NULL,
  policy_id INT,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id)
);

CREATE TABLE vendor_services (
  id INT PRIMARY KEY,
  service_type VARCHAR(20) NOT NULL,
  invoice_id INT,
  FOREIGN KEY (invoice_id) REFERENCES vendor_invoices(id)
);

CREATE TABLE department_projects (
  id INT PRIMARY KEY,
  project_name VARCHAR(50) NOT NULL,
  department_id INT,
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE employee_skills (
  id INT PRIMARY KEY,
  skill_name VARCHAR(20) NOT NULL,
  employee_id INT,
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE customer_feedback (
  id INT PRIMARY KEY,
  feedback_text TEXT NOT NULL,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE financial_advice (
  id INT PRIMARY KEY,
  advice_text TEXT NOT NULL,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE investment_premiums (
  id INT PRIMARY KEY,
  premium_amount DECIMAL(15, 2) NOT NULL,
  insurance_policy_id INT,
  FOREIGN KEY (insurance_policy_id) REFERENCES insurance_policies(id)
);

CREATE TABLE loan_applications (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  loan_amount DECIMAL(15, 2) NOT NULL,
  interest_rate DECIMAL(5, 2) NOT NULL,
  loan_term INT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE loan_repayments (
  id INT PRIMARY KEY,
  repayment_amount DECIMAL(15, 2) NOT NULL,
  loan_application_id INT,
  FOREIGN KEY (loan_application_id) REFERENCES loan_applications(id)
);

CREATE TABLE tax_return_amendments (
  id INT PRIMARY KEY,
  amendment_date DATE NOT NULL,
  original_tax_return_id INT,
  FOREIGN KEY (original_tax_return_id) REFERENCES tax_returns(id)
);

CREATE TABLE investment_transactions_history (
  id INT PRIMARY KEY,
  transaction_date DATE NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  investment_opportunity_id INT,
  FOREIGN KEY (investment_opportunity_id) REFERENCES investment_opportunities(id)
);

CREATE TABLE employee_training (
  id INT PRIMARY KEY,
  training_date DATE NOT NULL,
  skill_id INT,
  FOREIGN KEY (skill_id) REFERENCES employee_skills(id)
);

CREATE TABLE customer_service_requests (
  id INT PRIMARY KEY,
  request_date DATE NOT NULL,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE financial_planning_goals (
  id INT PRIMARY KEY,
  goal_name VARCHAR(50) NOT NULL,
  planning_id INT,
  FOREIGN KEY (planning_id) REFERENCES financial_planning(id)
);

CREATE TABLE insurance_policy_changes (
  id INT PRIMARY KEY,
  change_date DATE NOT NULL,
  policy_id INT,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id)
);

CREATE TABLE vendor_service_requests (
  id INT PRIMARY KEY,
  request_date DATE NOT NULL,
  invoice_id INT,
  FOREIGN KEY (invoice_id) REFERENCES vendor_invoices(id)
);

CREATE TABLE employee_evaluation_results (
  id INT PRIMARY KEY,
  evaluation_result DECIMAL(3, 2) NOT NULL,
  employee_id INT,
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE investment_opportunity_assessments (
  id INT PRIMARY KEY,
  assessment_date DATE NOT NULL,
  opportunity_id INT,
  FOREIGN KEY (opportunity_id) REFERENCES investment_opportunities(id)
);

CREATE TABLE loan_offers (
  id INT PRIMARY KEY,
  offer_amount DECIMAL(15, 2) NOT NULL,
  loan_application_id INT,
  FOREIGN KEY (loan_application_id) REFERENCES loan_applications(id)
);

CREATE TABLE investment_portfolios (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  portfolio_name VARCHAR(100) NOT NULL,
  total_value DECIMAL(15, 2) NOT NULL,
  created_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE investment_portfolio_updates (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  portfolio_id INT,
  FOREIGN KEY (portfolio_id) REFERENCES investment_portfolios(id)
);

CREATE TABLE employee_performance_ratings (
  id INT PRIMARY KEY,
  rating DECIMAL(3, 2) NOT NULL,
  employee_id INT,
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE customer_service_response_times (
  id INT PRIMARY KEY,
  response_time DECIMAL(5, 2) NOT NULL,
  service_request_id INT,
  FOREIGN KEY (service_request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE financial_planning_goal_updates (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE insurance_policy_cancellations (
  id INT PRIMARY KEY,
  cancellation_date DATE NOT NULL,
  policy_id INT,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id)
);

CREATE TABLE vendor_service_request_statuses (
  id INT PRIMARY KEY,
  status VARCHAR(20) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES vendor_service_requests(id)
);

CREATE TABLE employee_skill_level_updates (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  skill_id INT,
  FOREIGN KEY (skill_id) REFERENCES employee_skills(id)
);

CREATE TABLE investment_opportunity_assessment_results (
  id INT PRIMARY KEY,
  result DECIMAL(3, 2) NOT NULL,
  assessment_id INT,
  FOREIGN KEY (assessment_id) REFERENCES investment_opportunity_assessments(id)
);

CREATE TABLE customer_preferences (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  preference_type VARCHAR(50) NOT NULL,
  preference_value VARCHAR(100) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE account_types (
  id INT PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL,
  description TEXT
);

CREATE TABLE payment_methods (
  id INT PRIMARY KEY,
  method_name VARCHAR(50) NOT NULL,
  description TEXT
);

CREATE TABLE customer_notifications (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  notification_type VARCHAR(50) NOT NULL,
  notification_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE transaction_fees (
  id INT PRIMARY KEY,
  transaction_id INT NOT NULL,
  fee_amount DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id)
);

CREATE TABLE loan_types (
  id INT PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL,
  description TEXT
);

CREATE TABLE employee_roles (
  id INT PRIMARY KEY,
  role_name VARCHAR(50) NOT NULL,
  description TEXT
);

CREATE TABLE customer_addresses (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  address VARCHAR(200) NOT NULL,
  city VARCHAR(50) NOT NULL,
  state VARCHAR(2) NOT NULL,
  zip_code VARCHAR(10) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE customer_contacts (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  contact_type VARCHAR(50) NOT NULL,
  contact_value VARCHAR(100) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE employee_shifts (
  id INT PRIMARY KEY,
  employee_id INT NOT NULL,
  shift_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE department_heads (
  id INT PRIMARY KEY,
  department_id INT NOT NULL,
  employee_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(id),
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE customer_rewards (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  reward_points INT NOT NULL,
  reward_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE system_logs (
  id INT PRIMARY KEY,
  log_date TIMESTAMP NOT NULL,
  log_level VARCHAR(10) NOT NULL,
  message TEXT NOT NULL
);

CREATE TABLE audit_trails (
  id INT PRIMARY KEY,
  action_date TIMESTAMP NOT NULL,
  action_type VARCHAR(50) NOT NULL,
  user_id INT NOT NULL,
  description TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES employees(id)
);

CREATE TABLE subscription_plans (
  id INT PRIMARY KEY,
  plan_name VARCHAR(50) NOT NULL,
  plan_description TEXT,
  monthly_fee DECIMAL(15, 2) NOT NULL
);


CREATE TABLE customer_relationship_manager (
  id INT PRIMARY KEY,
  manager_name VARCHAR(50) NOT NULL,
  department_id INT,
  customer_id INT,
  FOREIGN KEY (department_id) REFERENCES departments(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE investment_opportunity_analysis_results (
  id INT PRIMARY KEY,
  result DECIMAL(3, 2) NOT NULL,
  opportunity_id INT,
  analyst_id INT,
  FOREIGN KEY (opportunity_id) REFERENCES investment_opportunities(id),
  FOREIGN KEY (analyst_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_status_updates (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  goal_id INT,
  status VARCHAR(20) NOT NULL,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE insurance_policy_coverage_updates (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  policy_id INT,
  coverage DECIMAL(3, 2) NOT NULL,
  adjuster_id INT,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id),
  FOREIGN KEY (adjuster_id) REFERENCES employees(id)
);

CREATE TABLE vendor_service_request_item (
  id INT PRIMARY KEY,
  item_name VARCHAR(50) NOT NULL,
  request_id INT,
  quantity DECIMAL(3, 2) NOT NULL,
  price DECIMAL(5, 2) NOT NULL,
  FOREIGN KEY (request_id) REFERENCES vendor_service_requests(id)
);

CREATE TABLE employee_performance_goals (
  id INT PRIMARY KEY,
  goal_name VARCHAR(50) NOT NULL,
  performance_id INT,
  target DECIMAL(3, 2) NOT NULL,
  employee_id INT,
  FOREIGN KEY (performance_id) REFERENCES employee_performance_ratings(id),
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE investment_portfolio_assets (
  id INT PRIMARY KEY,
  asset_name VARCHAR(50) NOT NULL,
  portfolio_id INT,
  quantity DECIMAL(3, 2) NOT NULL,
  value DECIMAL(5, 2) NOT NULL,
  FOREIGN KEY (portfolio_id) REFERENCES investment_portfolios(id)
);

CREATE TABLE customer_service_request_feedback (
  id INT PRIMARY KEY,
  feedback TEXT NOT NULL,
  request_id INT,
  customer_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE financial_planning_goal_categories (
  id INT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE customer_loyalty (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  loyalty_points INT NOT NULL,
  last_updated DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE account_statements (
  id INT PRIMARY KEY,
  account_id INT NOT NULL,
  statement_date DATE NOT NULL,
  balance DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (account_id) REFERENCES accounts(id)
);

CREATE TABLE promotional_offers (
  id INT PRIMARY KEY,
  offer_name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL
);

CREATE TABLE customer_promotions (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  promotion_id INT NOT NULL,
  assigned_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (promotion_id) REFERENCES promotional_offers(id)
);

CREATE TABLE account_alerts (
  id INT PRIMARY KEY,
  account_id INT NOT NULL,
  alert_type VARCHAR(50) NOT NULL,
  alert_date DATE NOT NULL,
  message TEXT NOT NULL,
  FOREIGN KEY (account_id) REFERENCES accounts(id)
);

CREATE TABLE investment_advisors (
  id INT PRIMARY KEY,
  advisor_name VARCHAR(100) NOT NULL,
  contact_info VARCHAR(100) NOT NULL
);

CREATE TABLE customer_investment_advisors (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  advisor_id INT NOT NULL,
  assigned_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (advisor_id) REFERENCES investment_advisors(id)
);

CREATE TABLE financial_planning_sessions (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  session_date DATE NOT NULL,
  summary TEXT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE marketing_campaigns (
  id INT PRIMARY KEY,
  campaign_name VARCHAR(100) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  budget DECIMAL(15, 2) NOT NULL
);

CREATE TABLE campaign_customers (
  id INT PRIMARY KEY,
  campaign_id INT NOT NULL,
  customer_id INT NOT NULL,
  participation_date DATE NOT NULL,
  FOREIGN KEY (campaign_id) REFERENCES marketing_campaigns(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE regulatory_compliance (
  id INT PRIMARY KEY,
  compliance_date DATE NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(50) NOT NULL
);

CREATE TABLE audit_reports (
  id INT PRIMARY KEY,
  report_date DATE NOT NULL,
  findings TEXT NOT NULL,
  compliance_id INT,
  FOREIGN KEY (compliance_id) REFERENCES regulatory_compliance(id)
);

CREATE TABLE internal_audits (
  id INT PRIMARY KEY,
  audit_date DATE NOT NULL,
  department_id INT NOT NULL,
  summary TEXT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE service_levels (
  id INT PRIMARY KEY,
  service_name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  sla_agreement TEXT NOT NULL
);

CREATE TABLE customer_service_levels (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  service_level_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (service_level_id) REFERENCES service_levels(id)
);

CREATE TABLE insurance_policy_claims (
  id INT PRIMARY KEY,
  claim_date DATE NOT NULL,
  policy_id INT,
  amount DECIMAL(15, 2) NOT NULL,
  adjuster_id INT,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id),
  FOREIGN KEY (adjuster_id) REFERENCES employees(id)
);

CREATE TABLE investment_opportunity_recommendation (
  id INT PRIMARY KEY,
  recommendation VARCHAR(50) NOT NULL,
  opportunity_id INT,
  analyst_id INT,
  FOREIGN KEY (opportunity_id) REFERENCES investment_opportunities(id),
  FOREIGN KEY (analyst_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_priority (
  id INT PRIMARY KEY,
  priority DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE employee_relationship_managers (
  id INT PRIMARY KEY,
  employee_id INT NOT NULL,
  manager_id INT NOT NULL,
  relationship_start_date DATE NOT NULL,
  relationship_end_date DATE,
  FOREIGN KEY (employee_id) REFERENCES employees(id),
  FOREIGN KEY (manager_id) REFERENCES employees(id)
);

CREATE TABLE customer_relationship_manager_feedback (
  id INT PRIMARY KEY,
  feedback TEXT NOT NULL,
  manager_id INT,
  department_id INT,
  FOREIGN KEY (manager_id) REFERENCES employee_relationship_managers(id),
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE insurance_policy_coverage_type (
  id INT PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL,
  policy_id INT,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id)
);

CREATE TABLE investment_portfolio_asset_category (
  id INT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  portfolio_id INT,
  FOREIGN KEY (portfolio_id) REFERENCES investment_portfolios(id)
);

CREATE TABLE financial_planning_goal_target_updates (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  goal_id INT,
  target DECIMAL(3, 2) NOT NULL,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE employee_performance_goal_category (
  id INT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id)
);

CREATE TABLE asset_management (
  id INT PRIMARY KEY,
  asset_name VARCHAR(100) NOT NULL,
  purchase_date DATE NOT NULL,
  purchase_price DECIMAL(15, 2) NOT NULL,
  current_value DECIMAL(15, 2) NOT NULL
);

CREATE TABLE asset_depreciation (
  id INT PRIMARY KEY,
  asset_id INT NOT NULL,
  depreciation_date DATE NOT NULL,
  depreciation_amount DECIMAL(15, 2) NOT NULL,
  FOREIGN KEY (asset_id) REFERENCES asset_management(id)
);

CREATE TABLE customer_support_tickets (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  issue_description TEXT NOT NULL,
  ticket_status VARCHAR(20) NOT NULL,
  creation_date DATE NOT NULL,
  resolution_date DATE,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE employee_attendance (
  id INT PRIMARY KEY,
  employee_id INT NOT NULL,
  attendance_date DATE NOT NULL,
  status VARCHAR(10) NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE training_programs (
  id INT PRIMARY KEY,
  program_name VARCHAR(100) NOT NULL,
  description TEXT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL
);

CREATE TABLE employee_training_sessions (
  id INT PRIMARY KEY,
  employee_id INT NOT NULL,
  program_id INT NOT NULL,
  session_date DATE NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(id),
  FOREIGN KEY (program_id) REFERENCES training_programs(id)
);

CREATE TABLE marketing_campaign_metrics (
  id INT PRIMARY KEY,
  campaign_id INT NOT NULL,
  metric_name VARCHAR(50) NOT NULL,
  metric_value DECIMAL(15, 2) NOT NULL,
  measurement_date DATE NOT NULL,
  FOREIGN KEY (campaign_id) REFERENCES marketing_campaigns(id)
);

CREATE TABLE vendor_contracts (
  id INT PRIMARY KEY,
  vendor_name VARCHAR(100) NOT NULL,
  contract_start_date DATE NOT NULL,
  contract_end_date DATE NOT NULL,
  contract_value DECIMAL(15, 2) NOT NULL
);

CREATE TABLE customer_loyalty_rewards (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  reward_description TEXT NOT NULL,
  reward_date DATE NOT NULL,
  points_earned INT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE regulatory_fines (
  id INT PRIMARY KEY,
  fine_date DATE NOT NULL,
  fine_amount DECIMAL(15, 2) NOT NULL,
  compliance_id INT,
  FOREIGN KEY (compliance_id) REFERENCES regulatory_compliance(id)
);

CREATE TABLE project_management (
  id INT PRIMARY KEY,
  project_name VARCHAR(100) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  budget DECIMAL(15, 2) NOT NULL,
  department_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE project_tasks (
  id INT PRIMARY KEY,
  project_id INT NOT NULL,
  task_name VARCHAR(100) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  task_status VARCHAR(20) NOT NULL,
  FOREIGN KEY (project_id) REFERENCES project_management(id)
);

CREATE TABLE sales_forecasts (
  id INT PRIMARY KEY,
  forecast_date DATE NOT NULL,
  projected_sales DECIMAL(15, 2) NOT NULL,
  actual_sales DECIMAL(15, 2)
);

CREATE TABLE customer_segments (
  id INT PRIMARY KEY,
  segment_name VARCHAR(50) NOT NULL,
  description TEXT NOT NULL
);

CREATE TABLE customer_segment_assignments (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  segment_id INT NOT NULL,
  assignment_date DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (segment_id) REFERENCES customer_segments(id)
);

CREATE TABLE investment_opportunity_rating (
  id INT PRIMARY KEY,
  rating DECIMAL(3, 2) NOT NULL,
  opportunity_id INT,
  analyst_id INT,
  FOREIGN KEY (opportunity_id) REFERENCES investment_opportunities(id),
  FOREIGN KEY (analyst_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_status (
  id INT PRIMARY KEY,
  status VARCHAR(20) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE insurance_policy_claim_status (
  id INT PRIMARY KEY,
  status VARCHAR(20) NOT NULL,
  claim_id INT,
  adjuster_id INT,
  FOREIGN KEY (claim_id) REFERENCES insurance_policy_claims(id),
  FOREIGN KEY (adjuster_id) REFERENCES employees(id)
);

CREATE TABLE customer_relationship_manager_eval (
  id INT PRIMARY KEY,
  evaluation DECIMAL(3, 2) NOT NULL,
  manager_id INT,
  department_id INT,
  FOREIGN KEY (manager_id) REFERENCES employee_relationship_managers(id),
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE investment_portfolio_asset_value (
  id INT PRIMARY KEY,
  value DECIMAL(5, 2) NOT NULL,
  asset_id INT,
  portfolio_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id),
  FOREIGN KEY (portfolio_id) REFERENCES investment_portfolios(id)
);

CREATE TABLE customer_service_request_item (
  id INT PRIMARY KEY,
  item_name VARCHAR(50) NOT NULL,
  request_id INT,
  quantity DECIMAL(3, 2) NOT NULL,
  price DECIMAL(5, 2) NOT NULL,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE investment_opportunity_analysis (
  id INT PRIMARY KEY,
  result DECIMAL(3, 2) NOT NULL,
  opportunity_id INT,
  analyst_id INT,
  FOREIGN KEY (opportunity_id) REFERENCES investment_opportunities(id),
  FOREIGN KEY (analyst_id) REFERENCES employees(id)
);

CREATE TABLE insurance_policy_claim_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  claim_id INT,
  adjuster_id INT,
  FOREIGN KEY (claim_id) REFERENCES insurance_policy_claims(id),
  FOREIGN KEY (adjuster_id) REFERENCES employees(id)
);

CREATE TABLE employee_performance_goal_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE project_budget_allocations (
id INT PRIMARY KEY,
project_id INT NOT NULL,
allocation_amount DECIMAL(15, 2) NOT NULL,
allocation_date DATE NOT NULL,
FOREIGN KEY (project_id) REFERENCES project_management(id)
);

CREATE TABLE department_expense_reports (
id INT PRIMARY KEY,
department_id INT NOT NULL,
report_date DATE NOT NULL,
total_expenses DECIMAL(15, 2) NOT NULL,
FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE product_inventory (
id INT PRIMARY KEY,
product_name VARCHAR(100) NOT NULL,
quantity INT NOT NULL,
unit_price DECIMAL(15, 2) NOT NULL
);

CREATE TABLE inventory_transactions (
id INT PRIMARY KEY,
inventory_id INT NOT NULL,
transaction_date DATE NOT NULL,
quantity INT NOT NULL,
transaction_type VARCHAR(20) NOT NULL,
FOREIGN KEY (inventory_id) REFERENCES product_inventory(id)
);

CREATE TABLE employee_leave_requests (
id INT PRIMARY KEY,
employee_id INT NOT NULL,
request_date DATE NOT NULL,
leave_start_date DATE NOT NULL,
leave_end_date DATE NOT NULL,
status VARCHAR(20) NOT NULL,
FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE customer_demographics (
id INT PRIMARY KEY,
customer_id INT NOT NULL,
demographic_info VARCHAR(100) NOT NULL,
FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE vendor_contacts (
id INT PRIMARY KEY,
vendor_name VARCHAR(100) NOT NULL,
contact_name VARCHAR(100) NOT NULL,
contact_phone VARCHAR(15) NOT NULL,
contact_email VARCHAR(100) NOT NULL
);

CREATE TABLE marketing_campaign_performance (
id INT PRIMARY KEY,
campaign_id INT NOT NULL,
metric_name VARCHAR(50) NOT NULL,
metric_value DECIMAL(15, 2) NOT NULL,
measurement_date DATE NOT NULL,
FOREIGN KEY (campaign_id) REFERENCES marketing_campaigns(id)
);

CREATE TABLE business_partners (
id INT PRIMARY KEY,
partner_name VARCHAR(100) NOT NULL,
contact_info VARCHAR(100) NOT NULL
);

CREATE TABLE partner_contracts (
id INT PRIMARY KEY,
partner_id INT NOT NULL,
contract_details TEXT NOT NULL,
start_date DATE NOT NULL,
end_date DATE NOT NULL,
FOREIGN KEY (partner_id) REFERENCES business_partners(id)
);

CREATE TABLE supplier_invoices (
id INT PRIMARY KEY,
supplier_name VARCHAR(100) NOT NULL,
invoice_number VARCHAR(20) NOT NULL,
invoice_date DATE NOT NULL,
total_amount DECIMAL(15, 2) NOT NULL,
paid INT DEFAULT 0
);

CREATE TABLE supplier_payments (
id INT PRIMARY KEY,
invoice_id INT NOT NULL,
payment_date DATE NOT NULL,
amount DECIMAL(15, 2) NOT NULL,
FOREIGN KEY (invoice_id) REFERENCES supplier_invoices(id)
);

CREATE TABLE employee_work_hours (
id INT PRIMARY KEY,
employee_id INT NOT NULL,
work_date DATE NOT NULL,
hours_worked DECIMAL(5, 2) NOT NULL,
FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE payroll (
id INT PRIMARY KEY,
employee_id INT NOT NULL,
payment_date DATE NOT NULL,
amount DECIMAL(15, 2) NOT NULL,
FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE investment_risks (
id INT PRIMARY KEY,
investment_id INT NOT NULL,
risk_description TEXT NOT NULL,
risk_level VARCHAR(20) NOT NULL,
FOREIGN KEY (investment_id) REFERENCES investments(id)
);

CREATE TABLE investment_risk_mitigation (
id INT PRIMARY KEY,
risk_id INT NOT NULL,
mitigation_plan TEXT NOT NULL,
implementation_date DATE NOT NULL,
FOREIGN KEY (risk_id) REFERENCES investment_risks(id)
);

CREATE TABLE marketing_budget (
id INT PRIMARY KEY,
campaign_id INT NOT NULL,
budget_amount DECIMAL(15, 2) NOT NULL,
FOREIGN KEY (campaign_id) REFERENCES marketing_campaigns(id)
);

CREATE TABLE product_sales (
id INT PRIMARY KEY,
product_id INT NOT NULL,
sale_date DATE NOT NULL,
quantity_sold INT NOT NULL,
total_revenue DECIMAL(15, 2) NOT NULL,
FOREIGN KEY (product_id) REFERENCES product_inventory(id)
);

CREATE TABLE customer_discounts (
id INT PRIMARY KEY,
customer_id INT NOT NULL,
discount_description TEXT NOT NULL,
discount_amount DECIMAL(15, 2) NOT NULL,
discount_date DATE NOT NULL,
FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE employee_bonuses (
id INT PRIMARY KEY,
employee_id INT NOT NULL,
bonus_amount DECIMAL(15, 2) NOT NULL,
bonus_date DATE NOT NULL,
FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_action (
  id INT PRIMARY KEY,
  action_name VARCHAR(50) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE investment_portfolio_asset_type (
  id INT PRIMARY KEY,
  type_name VARCHAR(20) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_relationship_manager_tasks (
  id INT PRIMARY KEY,
  task_name VARCHAR(50) NOT NULL,
  manager_id INT,
  department_id INT,
  FOREIGN KEY (manager_id) REFERENCES employee_relationship_managers(id),
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE insurance_policy_coverage_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  policy_id INT,
  adjuster_id INT,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id),
  FOREIGN KEY (adjuster_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_target (
  id INT PRIMARY KEY,
  target DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_category_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  category_id INT,
  goal_id INT,
  FOREIGN KEY (category_id) REFERENCES financial_planning_goal_categories(id),
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE investment_portfolio_asset_value_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  asset_id INT,
  value DECIMAL(5, 2) NOT NULL,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_service_request_item_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  request_id INT,
  item_name VARCHAR(50) NOT NULL,
  quantity DECIMAL(3, 2) NOT NULL,
  price DECIMAL(5, 2) NOT NULL,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_action (
  id INT PRIMARY KEY,
  action_name VARCHAR(50) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE insurance_policy_coverage_analysis (
  id INT PRIMARY KEY,
  result DECIMAL(3, 2) NOT NULL,
  policy_id INT,
  adjuster_id INT,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id),
  FOREIGN KEY (adjuster_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_target_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  goal_id INT,
  target DECIMAL(3, 2) NOT NULL,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE investment_portfolio_asset_type_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  asset_id INT,
  type_name VARCHAR(20) NOT NULL,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_relationship_manager_task_item (
  id INT PRIMARY KEY,
  item_name VARCHAR(50) NOT NULL,
  task_id INT,
  manager_id INT,
  department_id INT,
  FOREIGN KEY (task_id) REFERENCES customer_relationship_manager_tasks(id),
  FOREIGN KEY (manager_id) REFERENCES employee_relationship_managers(id),
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE financial_planning_goal_category_item (
  id INT PRIMARY KEY,
  item_name VARCHAR(50) NOT NULL,
  category_id INT,
  goal_id INT,
  FOREIGN KEY (category_id) REFERENCES financial_planning_goal_categories(id),
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE investment_portfolio_asset_holding_period (
  id INT PRIMARY KEY,
  holding_period DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);


CREATE TABLE employee_performance_goal_metric (
  id INT PRIMARY KEY,
  metric DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE insurance_policy_coverage_update_item (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  policy_id INT,
  item_name VARCHAR(50) NOT NULL,
  coverage DECIMAL(3, 2) NOT NULL,
  FOREIGN KEY (policy_id) REFERENCES insurance_policies(id)
);

CREATE TABLE financial_planning_goal_target_item (
  id INT PRIMARY KEY,
  item_name VARCHAR(50) NOT NULL,
  target DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE customer_relationship_manager_task_item_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  task_id INT,
  item_name VARCHAR(50) NOT NULL,
  FOREIGN KEY (task_id) REFERENCES customer_relationship_manager_tasks(id)
);

CREATE TABLE insurance_policy_claim_item_update (
  id INT PRIMARY KEY,
  update_date DATE NOT NULL,
  claim_id INT,
  item_name VARCHAR(50) NOT NULL,
  FOREIGN KEY (claim_id) REFERENCES insurance_policy_claims(id)
);

CREATE TABLE financial_planning_goal_risk_assessment (
  id INT PRIMARY KEY,
  risk_level DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE investment_portfolio_asset_diversification (
  id INT PRIMARY KEY,
  diversification DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_service_request_category (
  id INT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_incentive (
  id INT PRIMARY KEY,
  incentive DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE insurance_policy_claim_resolution (
  id INT PRIMARY KEY,
  resolution DECIMAL(3, 2) NOT NULL,
  claim_id INT,
  adjuster_id INT,
  FOREIGN KEY (claim_id) REFERENCES insurance_policy_claims(id),
  FOREIGN KEY (adjuster_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_portfolio (
  id INT PRIMARY KEY,
  portfolio DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE investment_portfolio_asset_liquidity (
  id INT PRIMARY KEY,
  liquidity DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_service_request_priority (
  id INT PRIMARY KEY,
  priority DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_kpi (
  id INT PRIMARY KEY,
  kpi DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_scrutiny (
  id INT PRIMARY KEY,
  scrutiny DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE investment_portfolio_asset_maturity (
  id INT PRIMARY KEY,
  maturity DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_service_request_frequency (
  id INT PRIMARY KEY,
  frequency DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_milestone (
  id INT PRIMARY KEY,
  milestone DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE insurance_policy_claim_payment (
  id INT PRIMARY KEY,
  payment DECIMAL(3, 2) NOT NULL,
  claim_id INT,
  adjuster_id INT,
  FOREIGN KEY (claim_id) REFERENCES insurance_policy_claims(id),
  FOREIGN KEY (adjuster_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_analysis (
  id INT PRIMARY KEY,
  analysis DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE investment_portfolio_asset_return (
  id INT PRIMARY KEY,
  return DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_service_request_status (
  id INT PRIMARY KEY,
  status DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_recognition (
  id INT PRIMARY KEY,
  recognition DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE investment_portfolio_asset_valuation (
  id INT PRIMARY KEY,
  valuation DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_service_request_classification (
  id INT PRIMARY KEY,
  classification DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_coaching (
  id INT PRIMARY KEY,
  coaching DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  coach_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (coach_id) REFERENCES employees(id)
);

CREATE TABLE insurance_policy_claim_investigation (
  id INT PRIMARY KEY,
  investigation DECIMAL(3, 2) NOT NULL,
  claim_id INT,
  investigator_id INT,
  FOREIGN KEY (claim_id) REFERENCES insurance_policy_claims(id),
  FOREIGN KEY (investigator_id) REFERENCES employees(id)
);

CREATE TABLE customer_service_request_attachment (
  id INT PRIMARY KEY,
  attachment DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_innovation (
  id INT PRIMARY KEY,
  innovation DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE insurance_policy_claim_dispute (
  id INT PRIMARY KEY,
  dispute DECIMAL(3, 2) NOT NULL,
  claim_id INT,
  adjuster_id INT,
  FOREIGN KEY (claim_id) REFERENCES insurance_policy_claims(id),
  FOREIGN KEY (adjuster_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_stakeholder_analysis (
  id INT PRIMARY KEY,
  stakeholder_analysis DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE investment_portfolio_asset_hedging (
  id INT PRIMARY KEY,
  hedging DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE employee_performance_goal_communication (
  id INT PRIMARY KEY,
  communication DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE customer_service_request_follow_up (
  id INT PRIMARY KEY,
  follow_up DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE financial_planning_goal_revenue_forecasting (
  id INT PRIMARY KEY,
  revenue_forecasting DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE investment_portfolio_asset_collateralization (
  id INT PRIMARY KEY,
  collateralization DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE employee_performance_goal_quality_improvement (
  id INT PRIMARY KEY,
  quality_improvement DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_sustainability (
  id INT PRIMARY KEY,
  sustainability DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE investment_portfolio_asset_rebalancing (
  id INT PRIMARY KEY,
  rebalancing DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE employee_performance_goal_team_building (
  id INT PRIMARY KEY,
  team_building DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE customer_service_request_workaround (
  id INT PRIMARY KEY,
  workaround DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_delegation (
  id INT PRIMARY KEY,
  delegation DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_diversification (
  id INT PRIMARY KEY,
  diversification DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE customer_service_request_triage (
  id INT PRIMARY KEY,
  triage DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_time_management (
  id INT PRIMARY KEY,
  time_management DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_inflation (
  id INT PRIMARY KEY,
  inflation DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE investment_portfolio_asset_yield (
  id INT PRIMARY KEY,
  yield DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_service_request_alert (
  id INT PRIMARY KEY,
  alert DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE financial_planning_goal_liquidity (
  id INT PRIMARY KEY,
  liquidity DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE investment_portfolio_asset_volatility (
  id INT PRIMARY KEY,
  volatility DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_service_request_archive (
  id INT PRIMARY KEY,
  archive DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_prioritization (
  id INT PRIMARY KEY,
  prioritization DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

CREATE TABLE financial_planning_goal_risk_management (
  id INT PRIMARY KEY,
  risk_management DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  FOREIGN KEY (goal_id) REFERENCES financial_planning_goals(id)
);

CREATE TABLE investment_portfolio_asset_credit_rating (
  id INT PRIMARY KEY,
  credit_rating DECIMAL(3, 2) NOT NULL,
  asset_id INT,
  FOREIGN KEY (asset_id) REFERENCES investment_portfolio_assets(id)
);

CREATE TABLE customer_service_request_dashboard (
  id INT PRIMARY KEY,
  dashboard DECIMAL(3, 2) NOT NULL,
  request_id INT,
  FOREIGN KEY (request_id) REFERENCES customer_service_requests(id)
);

CREATE TABLE employee_performance_goal_workload (
  id INT PRIMARY KEY,
  workload DECIMAL(3, 2) NOT NULL,
  goal_id INT,
  planner_id INT,
  FOREIGN KEY (goal_id) REFERENCES employee_performance_goals(id),
  FOREIGN KEY (planner_id) REFERENCES employees(id)
);

-- temporary
CREATE TEMPORARY TABLE temp_customer_accounts AS
SELECT c.id AS customer_id, c.name, a.account_type, a.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id
WHERE c.state = 'CA';

CREATE TABLE customer_accounts_transactions AS
SELECT t.*, tca.*
FROM temp_customer_accounts tca
JOIN transactions t ON tca.customer_id = t.account_id;

CREATE TEMPORARY TABLE temp_customer_invoices AS
SELECT c.id AS customer_id, c.name, i.invoice_date, i.total
FROM customers c
JOIN invoices i ON c.id = i.customer_id
WHERE c.city = 'New York';

CREATE TABLE customer_invoices_payments AS
SELECT p.*, tci.*
FROM temp_customer_invoices tci
JOIN payments p ON tci.customer_id = p.invoice_id;

CREATE TEMPORARY TABLE temp_employee_departments AS
SELECT e.id AS employee_id, e.first_name, e.last_name, d.name AS department_name
FROM employees e
JOIN departments d ON e.id = d.id
WHERE d.name = 'Sales';

CREATE TABLE employee_departments_salaries AS
SELECT s.*, ted.first_name, ted.last_name
FROM temp_employee_departments ted
JOIN salaries s ON ted.employee_id = s.employee_id;

CREATE TEMPORARY TABLE temp_credit_card_transactions AS
SELECT cc.id AS card_id, cc.card_number, cct.transaction_date, cct.amount
FROM credit_cards cc
JOIN credit_card_transactions cct ON cc.id = cct.credit_card_id
WHERE cct.amount > 1000;

CREATE TABLE credit_card_transactions_customers AS
SELECT c.*, tcct.*
FROM temp_credit_card_transactions tcct
JOIN customers c ON tcct.card_id = c.id;

CREATE TEMPORARY TABLE temp_loan_payments AS
SELECT l.id AS loan_id, l.loan_amount, l.interest_rate, lp.payment_date, lp.amount
FROM loans l
JOIN loan_payments lp ON l.id = lp.loan_id
WHERE l.loan_term > 12;

CREATE TABLE loan_payments_customers AS
SELECT c.*, tlp.*
FROM temp_loan_payments tlp
JOIN customers c ON tlp.loan_id = c.id;



CREATE TEMPORARY TABLE temp_investment_transactions AS
SELECT i.id AS investment_id, i.investment_type, it.transaction_date, it.amount
FROM investments i
JOIN investment_transactions it ON i.id = it.investment_id
WHERE i.investment_type = 'Stocks';

CREATE TABLE investment_transactions_customers AS
SELECT c.*, tit.*
FROM temp_investment_transactions tit
JOIN customers c ON tit.investment_id = c.id;




CREATE TEMPORARY TABLE temp_insurance_claims AS
SELECT ip.id AS policy_id, ip.policy_type, ic.claim_date, ic.amount
FROM insurance_policies ip
JOIN insurance_claims ic ON ip.id = ic.policy_id
WHERE ic.amount > 5000;

CREATE TABLE insurance_claims_customers AS
SELECT c.*, tic.*
FROM temp_insurance_claims tic
JOIN customers c ON tic.policy_id = c.id;



CREATE TEMPORARY TABLE temp_tax_payments AS
SELECT tr.id AS return_id, tr.total_income, tp.payment_date, tp.amount
FROM tax_returns tr
JOIN tax_payments tp ON tr.id = tp.return_id
WHERE tr.filing_status = 'Married';

CREATE TABLE tax_payments_customers AS
SELECT c.*, ttp.*
FROM temp_tax_payments ttp
JOIN customers c ON ttp.return_id = c.id;




CREATE TEMPORARY TABLE temp_vendor_payments AS
SELECT vi.id AS invoice_id, vi.invoice_number, vp.payment_date, vp.amount
FROM vendor_invoices vi
JOIN vendor_payments vp ON vi.id = vp.invoice_id
WHERE vi.invoice_date > '2023-01-01';

CREATE TABLE vendor_payments_departments AS
SELECT d.*, tvp.*
FROM temp_vendor_payments tvp
JOIN departments d ON tvp.invoice_id = d.id;




CREATE TEMPORARY TABLE temp_employee_expenses AS
SELECT ee.id AS expense_id, ee.employee_id, ee.expense_type, ee.amount
FROM employee_expenses ee
JOIN employees e ON ee.employee_id = e.id
WHERE ee.expense_type = 'Travel';

CREATE TABLE employee_expenses_departments AS
SELECT d.*, tee.*
FROM temp_employee_expenses tee
JOIN departments d ON tee.employee_id = d.id;



CREATE TEMPORARY TABLE temp_department_allocations AS
SELECT da.id AS allocation_id, da.department_id, da.allocation_amount
FROM department_allocations da
JOIN departments d ON da.department_id = d.id
WHERE da.allocation_amount > 20000;

CREATE TABLE department_allocations_employees AS
SELECT e.*, tda.*
FROM temp_department_allocations tda
JOIN employees e ON tda.department_id = e.id;



CREATE TEMPORARY TABLE temp_financial_reports AS
SELECT fr.id AS report_id, fr.total_income, fr.total_expense, bi.budget
FROM financial_reports fr
JOIN budget_items bi ON fr.id = bi.id
WHERE bi.budget > 10000;

CREATE TABLE financial_reports_departments AS
SELECT d.*, tfr.*
FROM temp_financial_reports tfr
JOIN departments d ON tfr.report_id = d.id;



CREATE TEMPORARY TABLE temp_financial_goals AS
SELECT fg.id AS goal_id, fg.goal_type, gt.tracked_date, gt.progress
FROM financial_goals fg
JOIN goal_tracker gt ON fg.id = gt.goal_id
WHERE gt.tracked_date > '2023-01-01';

CREATE TABLE financial_goals_employees AS
SELECT e.*, tfg.*
FROM temp_financial_goals tfg
JOIN employees e ON tfg.goal_id = e.id;




CREATE TEMPORARY TABLE temp_investment_opportunities AS
SELECT io.id AS opportunity_id, io.opportunity_name, ma.market_trend
FROM investment_opportunities io
JOIN market_analysis ma ON io.id = ma.investment_opportunity_id
WHERE io.investment_type = 'Real Estate';

CREATE TABLE investment_opportunities_customers AS
SELECT c.*, tio.*
FROM temp_investment_opportunities tio
JOIN customers c ON tio.opportunity_id = c.id;




CREATE TEMPORARY TABLE temp_portfolio_recommendations AS
SELECT pr.id AS recommendation_id, pr.recommended_investment, pr.customer_id
FROM portfolio_recommendations pr
JOIN customers c ON pr.customer_id = c.id
WHERE pr.recommended_investment > 5000;

CREATE TABLE portfolio_recommendations_employees AS
SELECT e.*, tpr.*
FROM temp_portfolio_recommendations tpr
JOIN employees e ON tpr.customer_id = e.id;



CREATE TEMPORARY TABLE temp_financial_planning AS
SELECT fp.id AS planning_id, fp.financial_goal, fp.employee_id
FROM financial_planning fp
JOIN employees e ON fp.employee_id = e.id
WHERE fp.financial_goal > 20000;

CREATE TABLE financial_planning_departments AS
SELECT d.*, tfp.*
FROM temp_financial_planning tfp
JOIN departments d ON tfp.employee_id = d.id;



CREATE TEMPORARY TABLE temp_tax_filing_status AS
SELECT tfs.id AS status_id, tfs.filing_status, tfs.customer_id
FROM tax_filing_status tfs
JOIN customers c ON tfs.customer_id = c.id
WHERE tfs.filing_status = 'Single';

CREATE TABLE tax_filing_status_returns AS
SELECT tr.*, ttfs.status_id
FROM temp_tax_filing_status ttfs
JOIN tax_returns tr ON ttfs.customer_id = tr.id;



CREATE TEMPORARY TABLE temp_insurance_coverage AS
SELECT ic.id AS coverage_id, ic.coverage_type, ip.policy_type, ip.customer_id
FROM insurance_coverage ic
JOIN insurance_policies ip ON ic.policy_id = ip.id
WHERE ip.policy_type = 'Health';

CREATE TABLE insurance_coverage_customers AS
SELECT c.*, tic.*
FROM temp_insurance_coverage tic
JOIN customers c ON tic.customer_id = c.id;



CREATE TEMPORARY TABLE temp_vendor_services AS
SELECT vs.id AS service_id, vs.service_type, vi.invoice_number, vi.total
FROM vendor_services vs
JOIN vendor_invoices vi ON vs.invoice_id = vi.id
WHERE vs.service_type = 'Consulting';

CREATE TABLE vendor_services_departments AS
SELECT d.*, tvs.*
FROM temp_vendor_services tvs
JOIN departments d ON tvs.service_id = d.id;



CREATE TEMPORARY TABLE temp_department_projects AS
SELECT dp.id AS project_id, dp.project_name, dp.department_id
FROM department_projects dp
JOIN departments d ON dp.department_id = d.id
WHERE dp.project_name = 'New Initiative';

CREATE TABLE department_projects_employees AS
SELECT e.*, tdp.*
FROM temp_department_projects tdp
JOIN employees e ON tdp.department_id = e.id;



CREATE TEMPORARY TABLE temp_customer_credit_cards AS
SELECT c.id AS customer_id, c.name, cc.id as creadit_card_id, cc.expiration_date
FROM customers c
JOIN credit_cards cc ON c.id = cc.customer_id
WHERE cc.expiration_date > CURRENT_DATE;

CREATE TABLE customer_credit_card_transactions AS
SELECT cct.*, tccc.*
FROM temp_customer_credit_cards tccc
JOIN credit_card_transactions cct ON tccc.creadit_card_id = cct.credit_card_id;



CREATE TEMPORARY TABLE temp_employee_salaries AS
SELECT e.id AS employee_id, e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.id = s.employee_id
WHERE s.salary > 70000;

CREATE TABLE employee_salaries_departments AS
SELECT d.*, tes.*
FROM temp_employee_salaries tes
JOIN departments d ON tes.employee_id = d.id;



CREATE TEMPORARY TABLE temp_account_transactions AS
SELECT a.id AS account_id, a.customer_id, t.transaction_date, t.amount
FROM accounts a
JOIN transactions t ON a.id = t.account_id
WHERE t.type = 'Deposit';

CREATE TABLE account_transactions_customers AS
SELECT c.*, tat.*
FROM temp_account_transactions tat
JOIN customers c ON tat.customer_id = c.id;



CREATE TEMPORARY TABLE temp_loan_due_payments AS
SELECT l.id AS loan_id, l.loan_amount, lp.payment_date, lp.amount
FROM loans l
JOIN loan_payments lp ON l.id = lp.loan_id
WHERE lp.payment_date < CURRENT_DATE;

CREATE TABLE loan_due_payments_employees AS
SELECT e.*, tldp.*
FROM temp_loan_due_payments tldp
JOIN employees e ON tldp.loan_id = e.id;



CREATE TEMPORARY TABLE temp_investment_opportunities_transactions AS
SELECT io.id AS opportunity_id, io.opportunity_name, it.transaction_date, it.amount
FROM investment_opportunities io
JOIN investment_transactions it ON io.id = it.investment_id
WHERE it.amount > 10000;

CREATE TABLE investment_transactions_opportunities_customers AS
SELECT c.*, tiot.*
FROM temp_investment_opportunities_transactions tiot
JOIN customers c ON tiot.opportunity_id = c.id;



CREATE TEMPORARY TABLE temp_insurance_claims_types AS
SELECT ip.id AS policy_id, ip.policy_type, ic.claim_date, ic.amount
FROM insurance_policies ip
JOIN insurance_claims ic ON ip.id = ic.policy_id
WHERE ic.type = 'Theft';

CREATE TABLE insurance_claims_departments AS
SELECT d.*, tict.*
FROM temp_insurance_claims_types tict
JOIN departments d ON tict.policy_id = d.id;



CREATE TEMPORARY TABLE temp_tax_payments_amount AS
SELECT tr.id AS return_id, tr.total_income, tp.payment_date, tp.amount
FROM tax_returns tr
JOIN tax_payments tp ON tr.id = tp.return_id
WHERE tp.amount > 2000;

CREATE TABLE tax_payments_employees AS
SELECT e.*, ttpa.*
FROM temp_tax_payments_amount ttpa
JOIN employees e ON ttpa.return_id = e.id;



CREATE TEMPORARY TABLE temp_vendor_due_payments AS
SELECT vi.id AS invoice_id, vi.invoice_number, vp.payment_date, vp.amount
FROM vendor_invoices vi
JOIN vendor_payments vp ON vi.id = vp.invoice_id
WHERE vi.invoice_date < CURRENT_DATE;

CREATE TABLE vendor_due_payments_departments AS
SELECT d.*, tvdp.*
FROM temp_vendor_due_payments tvdp
JOIN departments d ON tvdp.invoice_id = d.id;



CREATE TEMPORARY TABLE temp_department_expenses AS
SELECT ee.id AS expense_id, ee.employee_id, ee.expense_type, ee.amount, d.name AS department_name
FROM employee_expenses ee
JOIN departments d ON ee.employee_id = d.id
WHERE ee.expense_type = 'Entertainment';

CREATE TABLE department_expenses_employees AS
SELECT e.*, tde.*
FROM temp_department_expenses tde
JOIN employees e ON tde.employee_id = e.id;



CREATE TEMPORARY TABLE temp_financial_reports_budgets AS
SELECT fr.id AS report_id, fr.total_income, fr.total_expense, bc.category_name
FROM financial_reports fr
JOIN budget_categories bc ON fr.id = bc.id
WHERE fr.total_income > 50000;

CREATE TABLE financial_reports_departments_budgets AS
SELECT d.*, tfrb.*
FROM temp_financial_reports_budgets tfrb
JOIN departments d ON tfrb.report_id = d.id;



CREATE TEMPORARY TABLE temp_financial_goals_tracker AS
SELECT fg.id AS goal_id, fg.goal_type, gt.tracked_date, gt.progress
FROM financial_goals fg
JOIN goal_tracker gt ON fg.id = gt.goal_id
WHERE gt.tracked_date < '2023-01-01';

CREATE TABLE financial_goals_departments AS
SELECT d.*, tfg.*
FROM temp_financial_goals_tracker tfg
JOIN departments d ON tfg.goal_id = d.id;



CREATE TEMPORARY TABLE temp_investment_opportunities_date AS
SELECT io.id AS opportunity_id, io.opportunity_name, it.transaction_date, it.amount
FROM investment_opportunities io
JOIN investment_transactions it ON io.id = it.investment_id
WHERE it.transaction_date > '2023-01-01';

CREATE TABLE investment_opportunities_employees AS
SELECT e.*, tiod.*
FROM temp_investment_opportunities_date tiod
JOIN employees e ON tiod.opportunity_id = e.id;



CREATE TEMPORARY TABLE temp_portfolio_recommendations_date AS
SELECT pr.id AS recommendation_id, pr.recommended_investment, pr.customer_id
FROM portfolio_recommendations pr
JOIN customers c ON pr.customer_id = c.id
WHERE pr.recommendation_date > '2023-01-01';

CREATE TABLE portfolio_recommendations_departments AS
SELECT d.*, tprd.*
FROM temp_portfolio_recommendations_date tprd
JOIN departments d ON tprd.customer_id = d.id;



CREATE TEMPORARY TABLE temp_financial_planning_date AS
SELECT fp.id AS planning_id, fp.financial_goal, fp.employee_id
FROM financial_planning fp
JOIN employees e ON fp.employee_id = e.id
WHERE fp.planning_date > '2023-01-01';

CREATE TABLE financial_planning_employees_departments AS
SELECT d.*, tfpd.*
FROM temp_financial_planning_date tfpd
JOIN departments d ON tfpd.employee_id = d.id;



CREATE TEMPORARY TABLE temp_tax_filing_status_2 AS
SELECT tfs.id AS status_id, tfs.filing_status, tfs.customer_id
FROM tax_filing_status tfs
JOIN customers c ON tfs.customer_id = c.id
WHERE tfs.filing_status = 'Head of Household';

CREATE TABLE tax_filing_status_customers_departments AS
SELECT d.*, tfs.*
FROM temp_tax_filing_status_2 tfs
JOIN departments d ON tfs.customer_id = d.id;



CREATE TEMPORARY TABLE temp_insurance_policies AS
SELECT ic.id AS coverage_id, ic.coverage_type, ip.policy_type, ip.customer_id
FROM insurance_coverage ic
JOIN insurance_policies ip ON ic.policy_id = ip.id
WHERE ip.policy_type = 'Life';

CREATE TABLE insurance_policies_departments AS
SELECT d.*, tip.*
FROM temp_insurance_policies tip
JOIN departments d ON tip.customer_id = d.id;



CREATE TEMPORARY TABLE temp_vendor_services_date AS
SELECT vs.id AS service_id, vs.service_type, vi.invoice_number, vi.total
FROM vendor_services vs
JOIN vendor_invoices vi ON vs.invoice_id = vi.id
WHERE vi.invoice_date > '2023-01-01';

CREATE TABLE vendor_services_invoices_departments AS
SELECT d.*, tvsd.*
FROM temp_vendor_services_date tvsd
JOIN departments d ON tvsd.service_id = d.id;



CREATE TEMPORARY TABLE temp_customer_feedback AS
SELECT cf.id AS feedback_id, cf.feedback_text, cf.customer_id
FROM customer_feedback cf
JOIN customers c ON cf.customer_id = c.id;

CREATE TABLE customer_feedback_employees AS
SELECT e.*, tcf.*
FROM temp_customer_feedback tcf
JOIN employees e ON tcf.customer_id = e.id;



CREATE TEMPORARY TABLE temp_financial_advice AS
SELECT fa.id AS advice_id, fa.advice_text, fa.customer_id
FROM financial_advice fa
JOIN customers c ON fa.customer_id = c.id;

CREATE TABLE financial_advice_employees AS
SELECT e.*, tfa.*
FROM temp_financial_advice tfa
JOIN employees e ON tfa.customer_id = e.id;



CREATE TEMPORARY TABLE temp_investment_premiums AS
SELECT ip.id AS premium_id, ip.premium_amount, ip.insurance_policy_id
FROM investment_premiums ip
JOIN insurance_policies i ON ip.insurance_policy_id = i.id
WHERE ip.premium_amount > 1000;

CREATE TABLE investment_premiums_departments AS
SELECT d.*, tip.*
FROM temp_investment_premiums tip
JOIN departments d ON tip.insurance_policy_id = d.id;



CREATE TEMPORARY TABLE temp_tax_return_amendments AS
SELECT tra.id AS amendment_id, tra.original_tax_return_id, tra.amendment_date
FROM tax_return_amendments tra
JOIN tax_returns tr ON tra.original_tax_return_id = tr.id
WHERE tra.amendment_date > '2023-01-01';

CREATE TABLE tax_return_amendments_customers AS
SELECT c.*, ttra.*
FROM temp_tax_return_amendments ttra
JOIN customers c ON ttra.original_tax_return_id = c.id;



CREATE TEMPORARY TABLE temp_investment_transactions_history AS
SELECT ith.id AS transaction_id, ith.transaction_date, ith.amount, io.opportunity_name, io.id as opportunity_id
FROM investment_transactions_history ith
JOIN investment_opportunities io ON ith.investment_opportunity_id = io.id
WHERE ith.transaction_date > '2023-01-01';

CREATE TABLE investment_transactions_history_customers AS
SELECT c.*, tith.*
FROM temp_investment_transactions_history tith
JOIN customers c ON tith.opportunity_id = c.id;



CREATE TEMPORARY TABLE temp_employee_training AS
SELECT et.id AS training_id, es.id as skill_id, et.training_date, es.skill_name
FROM employee_training et
JOIN employee_skills es ON et.skill_id = es.id
WHERE et.training_date > '2023-01-01';

CREATE TABLE employee_training_departments AS
SELECT d.*, tet.*
FROM temp_employee_training tet
JOIN departments d ON tet.skill_id = d.id;



CREATE TEMPORARY TABLE temp_customer_service_requests AS
SELECT csr.id AS request_id, csr.request_date, csr.customer_id
FROM customer_service_requests csr
JOIN customers c ON csr.customer_id = c.id
WHERE csr.request_date > '2023-01-01';

CREATE TABLE customer_service_requests_employees AS
SELECT e.*, tcsr.*
FROM temp_customer_service_requests tcsr
JOIN employees e ON tcsr.customer_id = e.id;



CREATE TEMPORARY TABLE temp_financial_planning_goals AS
SELECT fpg.id AS goal_id, fpg.planning_id AS planning_id, fpg.goal_name, fp.financial_goal
FROM financial_planning_goals fpg
JOIN financial_planning fp ON fpg.planning_id = fp.id;

CREATE TABLE financial_planning_goals_employees AS
SELECT e.*, tfpg.*
FROM temp_financial_planning_goals tfpg
JOIN employees e ON tfpg.planning_id = e.id;



CREATE TEMPORARY TABLE temp_insurance_policy_changes AS
SELECT ipc.id AS change_id, ipc.policy_id AS policy_id, ipc.change_date, ip.policy_type
FROM insurance_policy_changes ipc
JOIN insurance_policies ip ON ipc.policy_id = ip.id
WHERE ipc.change_date > '2023-01-01';

CREATE TABLE insurance_policy_changes_departments AS
SELECT d.*, tipc.*
FROM temp_insurance_policy_changes tipc
JOIN departments d ON tipc.policy_id = d.id;



CREATE TEMPORARY TABLE temp_customer_accounts_balance AS
SELECT c.id AS customer_id, c.name, a.account_type, a.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id
WHERE a.balance > 5000;

CREATE TABLE customer_accounts_balance_transactions AS
SELECT t.*, tca.*
FROM temp_customer_accounts_balance tca
JOIN transactions t ON tca.customer_id = t.account_id;



CREATE TEMPORARY TABLE temp_customer_invoices_paid AS
SELECT c.id AS customer_id, c.name, i.invoice_date, i.total
FROM customers c
JOIN invoices i ON c.id = i.customer_id
WHERE i.paid = 1;

CREATE TABLE customer_invoices_paid_payments AS
SELECT p.*, tci.*
FROM temp_customer_invoices_paid tci
JOIN payments p ON tci.customer_id = p.invoice_id;



CREATE TEMPORARY TABLE temp_employee_departments_hr AS
SELECT e.id AS employee_id, e.first_name, e.last_name, d.name AS department_name
FROM employees e
JOIN departments d ON e.id = d.id
WHERE d.name = 'HR';

CREATE TABLE employee_departments_hr_salaries AS
SELECT s.*, ted.department_name
FROM temp_employee_departments_hr ted
JOIN salaries s ON ted.employee_id = s.employee_id;



CREATE TEMPORARY TABLE temp_credit_card_transactions_large AS
SELECT cc.id AS card_id, cc.card_number, cct.transaction_date, cct.amount
FROM credit_cards cc
JOIN credit_card_transactions cct ON cc.id = cct.credit_card_id
WHERE cct.amount > 5000;

CREATE TABLE credit_card_transactions_large_customers AS
SELECT c.*, tcct.*
FROM temp_credit_card_transactions_large tcct
JOIN customers c ON tcct.card_id = c.id;



CREATE TEMPORARY TABLE temp_loan_payments_large AS
SELECT l.id AS loan_id, l.loan_amount, l.interest_rate, lp.payment_date, lp.amount
FROM loans l
JOIN loan_payments lp ON l.id = lp.loan_id
WHERE lp.amount > 1000;

CREATE TABLE loan_payments_large_customers AS
SELECT c.*, tlp.*
FROM temp_loan_payments_large tlp
JOIN customers c ON tlp.loan_id = c.id;



CREATE TEMPORARY TABLE temp_investment_transactions_large AS
SELECT i.id AS investment_id, i.investment_type, it.transaction_date, it.amount
FROM investments i
JOIN investment_transactions it ON i.id = it.investment_id
WHERE it.amount > 10000;

CREATE TABLE investment_transactions_large_customers AS
SELECT c.*, tit.*
FROM temp_investment_transactions_large tit
JOIN customers c ON tit.investment_id = c.id;



CREATE TEMPORARY TABLE temp_insurance_claims_large AS
SELECT ip.id AS policy_id, ip.policy_type, ic.claim_date, ic.amount
FROM insurance_policies ip
JOIN insurance_claims ic ON ip.id = ic.policy_id
WHERE ic.amount > 10000;

CREATE TABLE insurance_claims_large_customers AS
SELECT c.*, tic.*
FROM temp_insurance_claims_large tic
JOIN customers c ON tic.policy_id = c.id;



CREATE TEMPORARY TABLE temp_vendor_payments_large AS
SELECT vi.id AS invoice_id, vi.invoice_number, vp.payment_date, vp.amount
FROM vendor_invoices vi
JOIN vendor_payments vp ON vi.id = vp.invoice_id
WHERE vp.amount > 5000;

CREATE TABLE vendor_payments_large_departments AS
SELECT d.*, tvp.*
FROM temp_vendor_payments_large tvp
JOIN departments d ON tvp.invoice_id = d.id;



CREATE TEMPORARY TABLE temp_employee_expenses_large AS
SELECT ee.id AS expense_id, ee.employee_id, ee.expense_type, ee.amount
FROM employee_expenses ee
JOIN employees e ON ee.employee_id = e.id
WHERE ee.amount > 500;

CREATE TABLE employee_expenses_large_departments AS
SELECT d.*, tee.*
FROM temp_employee_expenses_large tee
JOIN departments d ON tee.employee_id = d.id;



CREATE TEMPORARY TABLE temp_department_allocations_large AS
SELECT da.id AS allocation_id, da.department_id, da.allocation_amount
FROM department_allocations da
JOIN departments d ON da.department_id = d.id
WHERE da.allocation_amount > 50000;

CREATE TABLE department_allocations_large_employees AS
SELECT e.*, tda.*
FROM temp_department_allocations_large tda
JOIN employees e ON tda.department_id = e.id;



CREATE TEMPORARY TABLE temp_financial_reports_large AS
SELECT fr.id AS report_id, fr.total_income, fr.total_expense, fr.profit
FROM financial_reports fr
JOIN budget_items bi ON fr.id = bi.id
WHERE fr.profit > 50000;

CREATE TABLE financial_reports_large_departments AS
SELECT d.*, tfr.*
FROM temp_financial_reports_large tfr
JOIN departments d ON tfr.report_id = d.id;



CREATE TEMPORARY TABLE temp_financial_goals_large AS
SELECT fg.id AS goal_id, fg.goal_type, gt.tracked_date, gt.progress
FROM financial_goals fg
JOIN goal_tracker gt ON fg.id = gt.goal_id
WHERE fg.target_amount > 50000;

CREATE TABLE financial_goals_large_employees AS
SELECT e.*, tfg.*
FROM temp_financial_goals_large tfg
JOIN employees e ON tfg.goal_id = e.id;



CREATE TEMPORARY TABLE temp_investment_opportunities_large AS
SELECT io.id AS opportunity_id, io.opportunity_name, ma.market_trend
FROM investment_opportunities io
JOIN market_analysis ma ON io.id = ma.investment_opportunity_id
WHERE io.expected_return > 10;

CREATE TABLE investment_opportunities_large_customers AS
SELECT c.*, tio.*
FROM temp_investment_opportunities_large tio
JOIN customers c ON tio.opportunity_id = c.id;



CREATE TEMPORARY TABLE temp_portfolio_recommendations_large AS
SELECT pr.id AS recommendation_id, pr.recommended_investment, pr.customer_id
FROM portfolio_recommendations pr
JOIN customers c ON pr.customer_id = c.id
WHERE pr.recommended_investment > 10000;

CREATE TABLE portfolio_recommendations_large_departments AS
SELECT d.*, tpr.*
FROM temp_portfolio_recommendations_large tpr
JOIN departments d ON tpr.customer_id = d.id;



CREATE TEMPORARY TABLE temp_financial_planning_large AS
SELECT fp.id AS planning_id, fp.financial_goal, fp.employee_id
FROM financial_planning fp
JOIN employees e ON fp.employee_id = e.id
WHERE fp.financial_goal > 100000;

CREATE TABLE financial_planning_large_departments AS
SELECT d.*, tfp.*
FROM temp_financial_planning_large tfp
JOIN departments d ON tfp.employee_id = d.id;



CREATE TEMPORARY TABLE temp_insurance_policies_large AS
SELECT ic.id AS coverage_id, ic.coverage_type, ip.policy_type, ip.customer_id
FROM insurance_coverage ic
JOIN insurance_policies ip ON ic.policy_id = ip.id
WHERE ip.premium > 5000;

CREATE TABLE insurance_policies_large_departments AS
SELECT d.*, tip.*
FROM temp_insurance_policies_large tip
JOIN departments d ON tip.customer_id = d.id;



CREATE TEMPORARY TABLE temp_vendor_services_large AS
SELECT vs.id AS service_id, vs.service_type, vi.invoice_number, vi.total
FROM vendor_services vs
JOIN vendor_invoices vi ON vs.invoice_id = vi.id
WHERE vi.total > 5000;

CREATE TABLE vendor_services_large_departments AS
SELECT d.*, tvs.*
FROM temp_vendor_services_large tvs
JOIN departments d ON tvs.service_id = d.id;



CREATE TEMPORARY TABLE temp_customer_feedback_recent AS
SELECT cf.id AS feedback_id, cf.feedback_text, cf.customer_id
FROM customer_feedback cf
JOIN customers c ON cf.customer_id = c.id;

CREATE TABLE customer_feedback_recent_employees AS
SELECT e.*, tcf.*
FROM temp_customer_feedback_recent tcf
JOIN employees e ON tcf.customer_id = e.id;



CREATE TEMPORARY TABLE temp_financial_advice_recent AS
SELECT fa.id AS advice_id, fa.advice_text, fa.customer_id
FROM financial_advice fa
JOIN customers c ON fa.customer_id = c.id;

CREATE TABLE financial_advice_recent_employees AS
SELECT e.*, tfa.*
FROM temp_financial_advice_recent tfa
JOIN employees e ON tfa.customer_id = e.id;



CREATE TEMPORARY TABLE temp_investment_premiums_recent AS
SELECT ip.id AS premium_id, ip.premium_amount, ip.insurance_policy_id
FROM investment_premiums ip
JOIN insurance_policies i ON ip.insurance_policy_id = i.id;

CREATE TABLE investment_premiums_recent_departments AS
SELECT d.*, tip.*
FROM temp_investment_premiums_recent tip
JOIN departments d ON tip.insurance_policy_id = d.id;



CREATE TEMPORARY TABLE temp_tax_return_amendments_recent AS
SELECT tra.id AS amendment_id, tra.original_tax_return_id, tra.amendment_date
FROM tax_return_amendments tra
JOIN tax_returns tr ON tra.original_tax_return_id = tr.id
WHERE tra.amendment_date > '2023-06-01';

CREATE TABLE tax_return_amendments_recent_customers AS
SELECT c.*, ttra.*
FROM temp_tax_return_amendments_recent ttra
JOIN customers c ON ttra.original_tax_return_id = c.id;

CREATE TEMPORARY TABLE temp_customer_service_requests_recent AS
SELECT csr.id AS request_id, csr.request_date, csr.customer_id
FROM customer_service_requests csr
JOIN customers c ON csr.customer_id = c.id
WHERE csr.request_date > '2023-06-01';

CREATE TABLE customer_service_requests_recent_employees AS
SELECT e.*, tcsr.*
FROM temp_customer_service_requests_recent tcsr
JOIN employees e ON tcsr.customer_id = e.id;

CREATE TEMPORARY TABLE temp_vendor_services_recent_large AS
SELECT vs.id AS service_id, vs.service_type, vi.invoice_number, vi.total
FROM vendor_services vs
JOIN vendor_invoices vi ON vs.invoice_id = vi.id
WHERE vi.total > 5000 AND vi.invoice_date > '2023-06-01';

CREATE TABLE vendor_services_recent_large_departments AS
SELECT d.*, tvs.*
FROM temp_vendor_services_recent_large tvs
JOIN departments d ON tvs.service_id = d.id;

CREATE TEMPORARY TABLE temp_insurance_policies_recent_large AS
SELECT ic.id AS coverage_id, ic.coverage_type, ip.policy_type, ip.customer_id
FROM insurance_coverage ic
JOIN insurance_policies ip ON ic.policy_id = ip.id
WHERE ip.premium > 5000;

CREATE TABLE insurance_policies_recent_large_departments AS
SELECT d.*, tip.*
FROM temp_insurance_policies_recent_large tip
JOIN departments d ON tip.customer_id = d.id;

CREATE TEMPORARY TABLE temp_tax_filing_status_recent_large AS
SELECT tfs.id AS status_id, tfs.filing_status, tfs.customer_id
FROM tax_filing_status tfs
JOIN customers c ON tfs.customer_id = c.id
WHERE tfs.filing_status = 'Single';

CREATE TABLE tax_filing_status_recent_large_departments AS
SELECT d.*, tfs.*
FROM temp_tax_filing_status_recent_large tfs
JOIN departments d ON tfs.customer_id = d.id;

CREATE TEMPORARY TABLE temp_financial_planning_recent_large AS
SELECT fp.id AS planning_id, fp.financial_goal, fp.employee_id
FROM financial_planning fp
JOIN employees e ON fp.employee_id = e.id
WHERE fp.planning_date > '2023-06-01' AND fp.financial_goal > 100000;

CREATE TABLE financial_planning_recent_large_departments AS
SELECT d.*, tfp.*
FROM temp_financial_planning_recent_large tfp
JOIN departments d ON tfp.employee_id = d.id;

CREATE TEMPORARY TABLE temp_portfolio_recommendations_recent_large AS
SELECT pr.id AS recommendation_id, pr.recommended_investment, pr.customer_id
FROM portfolio_recommendations pr
JOIN customers c ON pr.customer_id = c.id
WHERE pr.recommendation_date > '2023-06-01' AND pr.recommended_investment > 10000;

CREATE TABLE portfolio_recommendations_recent_large_departments AS
SELECT d.*, tpr.*
FROM temp_portfolio_recommendations_recent_large tpr
JOIN departments d ON tpr.customer_id = d.id;

CREATE TEMPORARY TABLE temp_investment_opportunities_recent_large AS
SELECT io.id AS opportunity_id, io.opportunity_name, ma.market_trend
FROM investment_opportunities io
JOIN market_analysis ma ON io.id = ma.investment_opportunity_id
WHERE ma.analysis_date > '2023-06-01' AND io.expected_return > 10;

CREATE TABLE investment_opportunities_recent_large_customers AS
SELECT c.*, tio.*
FROM temp_investment_opportunities_recent_large tio
JOIN customers c ON tio.opportunity_id = c.id;

CREATE TEMPORARY TABLE temp_financial_goals_recent_large AS
SELECT fg.id AS goal_id, fg.goal_type, gt.tracked_date, gt.progress
FROM financial_goals fg
JOIN goal_tracker gt ON fg.id = gt.goal_id
WHERE gt.tracked_date > '2023-06-01' AND fg.target_amount > 50000;

CREATE TABLE financial_goals_recent_large_employees AS
SELECT e.*, tfg.*
FROM temp_financial_goals_recent_large tfg
JOIN employees e ON tfg.goal_id = e.id;

CREATE TEMPORARY TABLE temp_financial_reports_recent_large AS
SELECT fr.id AS report_id, fr.total_income, fr.total_expense, fr.profit
FROM financial_reports fr
JOIN budget_items bi ON fr.id = bi.id
WHERE fr.report_date > '2023-06-01' AND fr.profit > 50000;

CREATE TABLE financial_reports_recent_large_departments AS
SELECT d.*, tfr.*
FROM temp_financial_reports_recent_large tfr
JOIN departments d ON tfr.report_id = d.id;

CREATE TEMPORARY TABLE temp_department_allocations_recent_large AS
SELECT da.id AS allocation_id, da.department_id, da.allocation_amount
FROM department_allocations da
JOIN departments d ON da.department_id = d.id
WHERE da.allocation_amount > 50000;

CREATE TABLE department_allocations_recent_large_employees AS
SELECT e.*, tda.*
FROM temp_department_allocations_recent_large tda
JOIN employees e ON tda.department_id = e.id;

CREATE TEMPORARY TABLE temp_employee_expenses_recent_large AS
SELECT ee.id AS expense_id, ee.employee_id, ee.expense_type, ee.amount
FROM employee_expenses ee
JOIN employees e ON ee.employee_id = e.id
WHERE ee.amount > 500;

CREATE TABLE employee_expenses_recent_large_departments AS
SELECT d.*, tee.*
FROM temp_employee_expenses_recent_large tee
JOIN departments d ON tee.employee_id = d.id;

CREATE TEMPORARY TABLE temp_vendor_payments_recent_large AS
SELECT vi.id AS invoice_id, vi.invoice_number, vp.payment_date, vp.amount
FROM vendor_invoices vi
JOIN vendor_payments vp ON vi.id = vp.invoice_id
WHERE vp.payment_date > '2023-06-01' AND vp.amount > 5000;

CREATE TABLE vendor_payments_recent_large_departments AS
SELECT d.*, tvp.*
FROM temp_vendor_payments_recent_large tvp
JOIN departments d ON tvp.invoice_id = d.id;

CREATE TEMPORARY TABLE temp_tax_payments_recent_large AS
SELECT tr.id AS return_id, tr.total_income, tp.payment_date, tp.amount
FROM tax_returns tr
JOIN tax_payments tp ON tr.id = tp.return_id
WHERE tp.payment_date > '2023-06-01' AND tp.amount > 5000;

CREATE TABLE tax_payments_recent_large_customers AS
SELECT c.*, ttp.*
FROM temp_tax_payments_recent_large ttp
JOIN customers c ON ttp.return_id = c.id;

CREATE TEMPORARY TABLE temp_insurance_claims_recent_large AS
SELECT ip.id AS policy_id, ip.policy_type, ic.claim_date, ic.amount
FROM insurance_policies ip
JOIN insurance_claims ic ON ip.id = ic.policy_id
WHERE ic.claim_date > '2023-06-01' AND ic.amount > 10000;

CREATE TABLE insurance_claims_recent_large_customers AS
SELECT c.*, tic.*
FROM temp_insurance_claims_recent_large tic
JOIN customers c ON tic.policy_id = c.id;

CREATE TEMPORARY TABLE temp_investment_transactions_recent_large AS
SELECT i.id AS investment_id, i.investment_type, it.transaction_date, it.amount
FROM investments i
JOIN investment_transactions it ON i.id = it.investment_id
WHERE it.transaction_date > '2023-06-01' AND it.amount > 10000;

CREATE TABLE investment_transactions_recent_large_customers AS
SELECT c.*, tit.*
FROM temp_investment_transactions_recent_large tit
JOIN customers c ON tit.investment_id = c.id;

CREATE TEMPORARY TABLE temp_loan_payments_recent_large AS
SELECT l.id AS loan_id, l.loan_amount, l.interest_rate, lp.payment_date, lp.amount
FROM loans l
JOIN loan_payments lp ON l.id = lp.loan_id
WHERE lp.payment_date > '2023-06-01' AND lp.amount > 5000;

CREATE TABLE loan_payments_recent_large_customers AS
SELECT c.*, tlp.*
FROM temp_loan_payments_recent_large tlp
JOIN customers c ON tlp.loan_id = c.id;

CREATE TEMPORARY TABLE temp_credit_card_transactions_recent AS
SELECT cc.id AS card_id, cc.card_number, cct.transaction_date, cct.amount
FROM credit_cards cc
JOIN credit_card_transactions cct ON cc.id = cct.credit_card_id
WHERE cct.transaction_date > '2023-06-01';

CREATE TABLE credit_card_transactions_recent_customers AS
SELECT c.*, tcct.*
FROM temp_credit_card_transactions_recent tcct
JOIN customers c ON tcct.card_id = c.id;

CREATE TEMPORARY TABLE temp_employee_departments_recent AS
SELECT e.id AS employee_id, e.first_name, e.last_name, d.name AS department_name
FROM employees e
JOIN departments d ON e.id = d.id;

CREATE TABLE employee_departments_recent_salaries AS
SELECT s.*, ted.department_name
FROM temp_employee_departments_recent ted
JOIN salaries s ON ted.employee_id = s.employee_id;

CREATE TEMPORARY TABLE temp_customer_invoices_recent AS
SELECT c.id AS customer_id, c.name, i.invoice_date, i.total
FROM customers c
JOIN invoices i ON c.id = i.customer_id
WHERE i.invoice_date > '2023-06-01';

CREATE TABLE customer_invoices_recent_payments AS
SELECT p.*, tci.*
FROM temp_customer_invoices_recent tci
JOIN payments p ON tci.customer_id = p.invoice_id;

CREATE TEMPORARY TABLE temp_customer_accounts_recent AS
SELECT c.id AS customer_id, c.name, a.account_type, a.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id;

CREATE TABLE customer_accounts_recent_transactions AS
SELECT t.*, tca.*
FROM temp_customer_accounts_recent tca
JOIN transactions t ON tca.customer_id = t.account_id;

CREATE TEMPORARY TABLE temp_insurance_policy_changes_recent AS
SELECT ipc.id AS change_id, ipc.policy_id AS policy_id, ipc.change_date, ip.policy_type
FROM insurance_policy_changes ipc
JOIN insurance_policies ip ON ipc.policy_id = ip.id
WHERE ipc.change_date > '2023-06-01';

CREATE TABLE insurance_policy_changes_recent_departments AS
SELECT d.*, tipc.*
FROM temp_insurance_policy_changes_recent tipc
JOIN departments d ON tipc.policy_id = d.id;

CREATE TEMPORARY TABLE temp_financial_planning_goals_recent AS
SELECT fpg.id AS goal_id, fpg.planning_id AS planning_id, fpg.goal_name, fp.financial_goal
FROM financial_planning_goals fpg
JOIN financial_planning fp ON fpg.planning_id = fp.id;

CREATE TABLE financial_planning_goals_recent_employees AS
SELECT e.*, tfpg.*
FROM temp_financial_planning_goals_recent tfpg
JOIN employees e ON tfpg.planning_id = e.id;

CREATE TEMPORARY TABLE temp_employee_training_recent AS
SELECT et.id AS training_id, et.skill_id AS skill_id, et.training_date, es.skill_name
FROM employee_training et
JOIN employee_skills es ON et.skill_id = es.id
WHERE et.training_date > '2023-06-01';

CREATE TABLE employee_training_recent_departments AS
SELECT d.*, tet.*
FROM temp_employee_training_recent tet
JOIN departments d ON tet.skill_id = d.id;

CREATE TEMPORARY TABLE temp_investment_transactions_history_recent AS
SELECT ith.id AS transaction_id, io.id AS opportunity_id, ith.transaction_date, ith.amount, io.opportunity_name
FROM investment_transactions_history ith
JOIN investment_opportunities io ON ith.investment_opportunity_id = io.id
WHERE ith.transaction_date > '2023-06-01';

CREATE TABLE investment_transactions_history_recent_customers AS
SELECT c.*, tith.*
FROM temp_investment_transactions_history_recent tith
JOIN customers c ON tith.opportunity_id = c.id;

CREATE TEMPORARY TABLE temp_department_projects_large AS
SELECT dp.id AS project_id, dp.project_name, dp.department_id
FROM department_projects dp
JOIN departments d ON dp.department_id = d.id;

CREATE TABLE department_projects_large_employees AS
SELECT e.*, tdp.*
FROM temp_department_projects_large tdp
JOIN employees e ON tdp.department_id = e.id;

CREATE TEMPORARY TABLE temp_tax_filing_status_large AS
SELECT tfs.id AS status_id, tfs.filing_status, tfs.customer_id
FROM tax_filing_status tfs
JOIN customers c ON tfs.customer_id = c.id;

CREATE TABLE tax_filing_status_large_departments AS
SELECT d.*, tfs.*
FROM temp_tax_filing_status_large tfs
JOIN departments d ON tfs.customer_id = d.id;


-- Views

CREATE OR REPLACE VIEW customer_accounts_view AS
SELECT c.id AS customer_id, c.name, a.account_type, a.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id;

CREATE OR REPLACE VIEW customer_transactions_view AS
SELECT c.id AS customer_id, c.name, t.transaction_date, t.amount, t.type
FROM customers c
JOIN accounts a ON c.id = a.customer_id
JOIN transactions t ON a.id = t.account_id;

CREATE OR REPLACE VIEW customer_invoices_view AS
SELECT c.id AS customer_id, c.name, i.invoice_date, i.total, i.paid
FROM customers c
JOIN invoices i ON c.id = i.customer_id;

CREATE OR REPLACE VIEW customer_payments_view AS
SELECT c.id AS customer_id, c.name, p.payment_date, p.amount
FROM customers c
JOIN invoices i ON c.id = i.customer_id
JOIN payments p ON i.id = p.invoice_id;

CREATE OR REPLACE VIEW employee_salaries_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.id = s.employee_id;

CREATE OR REPLACE VIEW employee_expenses_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, ex.expense_type, ex.amount
FROM employees e
JOIN employee_expenses ex ON e.id = ex.employee_id;

CREATE OR REPLACE VIEW department_allocations_view AS
SELECT d.id AS department_id, d.name AS department_name, da.allocation_amount
FROM departments d
JOIN department_allocations da ON d.id = da.department_id;

CREATE OR REPLACE VIEW customer_credit_cards_view AS
SELECT c.id AS customer_id, c.name, cc.card_number, cc.expiration_date
FROM customers c
JOIN credit_cards cc ON c.id = cc.customer_id;

CREATE OR REPLACE VIEW customer_loans_view AS
SELECT c.id AS customer_id, c.name, l.loan_amount, l.interest_rate, l.loan_term
FROM customers c
JOIN loans l ON c.id = l.customer_id;

CREATE OR REPLACE VIEW customer_loan_payments_view AS
SELECT c.id AS customer_id, c.name, lp.payment_date, lp.amount
FROM customers c
JOIN loans l ON c.id = l.customer_id
JOIN loan_payments lp ON l.id = lp.loan_id;

CREATE OR REPLACE VIEW customer_investments_view AS
SELECT c.id AS customer_id, c.name, i.investment_type, i.amount
FROM customers c
JOIN investments i ON c.id = i.customer_id;

CREATE OR REPLACE VIEW customer_investment_transactions_view AS
SELECT c.id AS customer_id, c.name, it.transaction_date, it.amount, it.type
FROM customers c
JOIN investments i ON c.id = i.customer_id
JOIN investment_transactions it ON i.id = it.investment_id;

CREATE OR REPLACE VIEW customer_insurance_policies_view AS
SELECT c.id AS customer_id, c.name, ip.policy_type, ip.premium
FROM customers c
JOIN insurance_policies ip ON c.id = ip.customer_id;

CREATE OR REPLACE VIEW customer_insurance_claims_view AS
SELECT c.id AS customer_id, c.name, ic.claim_date, ic.amount, ic.type
FROM customers c
JOIN insurance_policies ip ON c.id = ip.customer_id
JOIN insurance_claims ic ON ip.id = ic.policy_id;

CREATE OR REPLACE VIEW customer_tax_returns_view AS
SELECT c.id AS customer_id, c.name, tr.filing_status, tr.total_income
FROM customers c
JOIN tax_returns tr ON c.id = tr.customer_id;

CREATE OR REPLACE VIEW customer_tax_payments_view AS
SELECT c.id AS customer_id, c.name, tp.payment_date, tp.amount
FROM customers c
JOIN tax_returns tr ON c.id = tr.customer_id
JOIN tax_payments tp ON tr.id = tp.return_id;

CREATE OR REPLACE VIEW employee_training_sessions_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, ts.training_date, ts.skill_id
FROM employees e
JOIN employee_skills es ON e.id = es.employee_id
JOIN employee_training ts ON es.id = ts.skill_id;

CREATE OR REPLACE VIEW department_projects_view AS
SELECT d.id AS department_id, d.name AS department_name, dp.project_name
FROM departments d
JOIN department_projects dp ON d.id = dp.department_id;

CREATE OR REPLACE VIEW customer_service_requests_view AS
SELECT c.id AS customer_id, c.name, csr.request_date
FROM customers c
JOIN customer_service_requests csr ON c.id = csr.customer_id;

CREATE OR REPLACE VIEW employee_leave_requests_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, lr.request_date, lr.leave_start_date, lr.leave_end_date, lr.status
FROM employees e
JOIN employee_leave_requests lr ON e.id = lr.employee_id;

CREATE OR REPLACE VIEW employee_evaluations_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, ev.evaluation_result
FROM employees e
JOIN employee_evaluation_results ev ON e.id = ev.employee_id;

CREATE OR REPLACE VIEW customer_feedback_view AS
SELECT c.id AS customer_id, c.name, cf.feedback_text
FROM customers c
JOIN customer_feedback cf ON c.id = cf.customer_id;

CREATE OR REPLACE VIEW customer_portfolio_assets_view AS
SELECT c.id AS customer_id, c.name, ipa.asset_name, ipa.quantity, ipa.value
FROM customers c
JOIN investment_portfolios ip ON c.id = ip.customer_id
JOIN investment_portfolio_assets ipa ON ip.id = ipa.portfolio_id;

CREATE OR REPLACE VIEW customer_tax_return_amendments_view AS
SELECT c.id AS customer_id, c.name, tra.amendment_date
FROM customers c
JOIN tax_returns tr ON c.id = tr.customer_id
JOIN tax_return_amendments tra ON tr.id = tra.original_tax_return_id;

CREATE OR REPLACE VIEW employee_performance_goals_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, epg.goal_name, epg.target
FROM employees e
JOIN employee_performance_goals epg ON e.id = epg.employee_id;

CREATE OR REPLACE VIEW customer_investment_opportunities_view AS
SELECT c.id AS customer_id, c.name, io.opportunity_name, io.investment_type, io.expected_return
FROM customers c
JOIN investment_opportunities io ON c.id = io.customer_id;

CREATE OR REPLACE VIEW employee_skills_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, es.skill_name
FROM employees e
JOIN employee_skills es ON e.id = es.employee_id;

CREATE OR REPLACE VIEW customer_account_statements_view AS
SELECT c.id AS customer_id, c.name, acs.statement_date, acs.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id
JOIN account_statements acs ON a.id = acs.account_id;

CREATE OR REPLACE VIEW customer_credit_card_transactions_view AS
SELECT c.id AS customer_id, c.name, cct.transaction_date, cct.amount
FROM customers c
JOIN credit_cards cc ON c.id = cc.customer_id
JOIN credit_card_transactions cct ON cc.id = cct.credit_card_id;

CREATE OR REPLACE VIEW employee_attendance_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, ea.attendance_date, ea.status
FROM employees e
JOIN employee_attendance ea ON e.id = ea.employee_id;

CREATE OR REPLACE VIEW customer_investments_transactions_view AS
SELECT c.id AS customer_id, c.name, i.investment_type, it.transaction_date, it.amount, it.type
FROM customers c
JOIN investments i ON c.id = i.customer_id
JOIN investment_transactions it ON i.id = it.investment_id;

CREATE OR REPLACE VIEW customer_promotional_offers_view AS
SELECT c.id AS customer_id, c.name, po.offer_name, po.description, po.start_date, po.end_date
FROM customers c
JOIN customer_promotions cp ON c.id = cp.customer_id
JOIN promotional_offers po ON cp.promotion_id = po.id;

CREATE OR REPLACE VIEW department_project_tasks_view AS
SELECT d.id AS department_id, d.name AS department_name, pt.task_name, pt.start_date, pt.end_date, pt.task_status
FROM departments d
JOIN project_management pm ON d.id = pm.department_id
JOIN project_tasks pt ON pm.id = pt.project_id;

CREATE OR REPLACE VIEW customer_financial_planning_sessions_view AS
SELECT c.id AS customer_id, c.name, fps.session_date, fps.summary
FROM customers c
JOIN financial_planning_sessions fps ON c.id = fps.customer_id;

CREATE OR REPLACE VIEW customer_loans_payments_view AS
SELECT c.id AS customer_id, c.name, l.loan_amount, l.interest_rate, lp.payment_date, lp.amount
FROM customers c
JOIN loans l ON c.id = l.customer_id
JOIN loan_payments lp ON l.id = lp.loan_id;

CREATE OR REPLACE VIEW customer_account_alerts_view AS
SELECT c.id AS customer_id, c.name, aa.alert_type, aa.alert_date, aa.message
FROM customers c
JOIN accounts a ON c.id = a.customer_id
JOIN account_alerts aa ON a.id = aa.account_id;

CREATE OR REPLACE VIEW customer_investment_advisors_view AS
SELECT c.id AS customer_id, c.name, ia.advisor_name, ia.contact_info
FROM customers c
JOIN customer_investment_advisors cia ON c.id = cia.customer_id
JOIN investment_advisors ia ON cia.advisor_id = ia.id;

CREATE OR REPLACE VIEW department_projects_budgets_view AS
SELECT d.id AS department_id, d.name AS department_name, pm.project_name, pb.allocation_amount, pb.allocation_date
FROM departments d
JOIN project_management pm ON d.id = pm.department_id
JOIN project_budget_allocations pb ON pm.id = pb.project_id;

CREATE OR REPLACE VIEW customer_service_levels_view AS
SELECT c.id AS customer_id, c.name, csl.service_level_id, sl.service_name, sl.description, sl.sla_agreement
FROM customers c
JOIN customer_service_levels csl ON c.id = csl.customer_id
JOIN service_levels sl ON csl.service_level_id = sl.id;

CREATE OR REPLACE VIEW customer_service_requests_feedback_view AS
SELECT c.id AS customer_id, c.name, csr.request_date
FROM customers c
JOIN customer_service_requests csr ON c.id = csr.customer_id
JOIN customer_service_request_feedback csf ON csr.id = csf.request_id;

CREATE OR REPLACE VIEW employee_performance_ratings_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, epr.rating
FROM employees e
JOIN employee_performance_ratings epr ON e.id = epr.employee_id;

CREATE OR REPLACE VIEW department_internal_audits_view AS
SELECT d.id AS department_id, d.name AS department_name, ia.audit_date, ia.summary
FROM departments d
JOIN internal_audits ia ON d.id = ia.department_id;

CREATE OR REPLACE VIEW customer_loyalty_points_view AS
SELECT c.id AS customer_id, c.name, cl.loyalty_points, cl.last_updated
FROM customers c
JOIN customer_loyalty cl ON c.id = cl.customer_id;

CREATE OR REPLACE VIEW customer_investment_portfolios_view AS
SELECT c.id AS customer_id, c.name, ip.portfolio_name, ip.total_value, ip.created_date
FROM customers c
JOIN investment_portfolios ip ON c.id = ip.customer_id;

CREATE OR REPLACE VIEW customer_market_analysis_view AS
SELECT c.id AS customer_id, c.name, ma.analysis_date, ma.market_trend
FROM customers c
JOIN investment_opportunities io ON c.id = io.customer_id
JOIN market_analysis ma ON io.id = ma.investment_opportunity_id;

CREATE OR REPLACE VIEW customer_financial_advice_view AS
SELECT c.id AS customer_id, c.name, fa.advice_text
FROM customers c
JOIN financial_advice fa ON c.id = fa.customer_id;

CREATE OR REPLACE VIEW employee_skills_training_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, es.skill_name, et.training_date
FROM employees e
JOIN employee_skills es ON e.id = es.employee_id
JOIN employee_training et ON es.id = et.skill_id;

CREATE OR REPLACE VIEW employee_shift_schedules_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, es.shift_date, es.start_time, es.end_time
FROM employees e
JOIN employee_shifts es ON e.id = es.employee_id;

CREATE OR REPLACE VIEW customer_demographics_view AS
SELECT c.id AS customer_id, c.name, cd.demographic_info
FROM customers c
JOIN customer_demographics cd ON c.id = cd.customer_id;

CREATE OR REPLACE VIEW employee_bonuses_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, eb.bonus_amount, eb.bonus_date
FROM employees e
JOIN employee_bonuses eb ON e.id = eb.employee_id;

CREATE OR REPLACE VIEW customer_loyalty_rewards_view AS
SELECT c.id AS customer_id, c.name, clr.reward_description, clr.reward_date, clr.points_earned
FROM customers c
JOIN customer_loyalty_rewards clr ON c.id = clr.customer_id;

CREATE OR REPLACE VIEW customer_relationship_managers_view AS
SELECT c.id AS customer_id, c.name, crm.manager_name, crm.department_id
FROM customers c
JOIN customer_relationship_manager crm ON c.id = crm.customer_id;

CREATE OR REPLACE VIEW employee_performance_goals_actions_view AS
SELECT e.id AS employee_id, e.first_name, e.last_name, epg.goal_name, epg.target, epga.action_name
FROM employees e
JOIN employee_performance_goals epg ON e.id = epg.employee_id
JOIN employee_performance_goal_action epga ON epg.id = epga.goal_id;