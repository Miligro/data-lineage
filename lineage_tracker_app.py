import sys
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QComboBox, QLineEdit, QPushButton, QVBoxLayout, QMessageBox, QMainWindow
from DatabasesManagement.postgres_management import PostgresDatabaseManagement
from DatabasesManagement.sqlserver_management import SQLServerDatabaseManagement
from DatabasesManagement.oracle_management import OracleDatabaseManagement
from Lineage.data_lineage import DataLineageGraph


class LineageTrackerApp(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("Temporary Lineage Tracker")
        self.logged_in = False
        self.db_metadata = None
        self.selected_db = ''
        self.init_ui()

    def init_ui(self):
        if not self.logged_in:
            self.show_login_form()
        else:
            self.show_main_view()

    def show_login_form(self):
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Login Form"))

        self.db_combo = QComboBox()
        self.db_combo.addItems(["PostgreSQL", "SQL Server", "Oracle"])
        layout.addWidget(self.db_combo)

        self.host_entry = QLineEdit()
        self.host_entry.setPlaceholderText("Host")
        layout.addWidget(self.host_entry)

        self.dbname_entry = QLineEdit()
        self.dbname_entry.setPlaceholderText("Database name")
        layout.addWidget(self.dbname_entry)

        self.user_entry = QLineEdit()
        self.user_entry.setPlaceholderText("Username")
        layout.addWidget(self.user_entry)

        self.password_entry = QLineEdit()
        self.password_entry.setEchoMode(QLineEdit.Password)
        self.password_entry.setPlaceholderText("Password")
        layout.addWidget(self.password_entry)

        self.port_entry = QLineEdit()
        self.port_entry.setPlaceholderText("Port")
        layout.addWidget(self.port_entry)

        login_button = QPushButton("Login")
        login_button.clicked.connect(self.login)
        layout.addWidget(login_button)

        wid = QWidget(self)
        self.setCentralWidget(wid)
        wid.setLayout(layout)

    def show_main_view(self):
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Main View"))

        install_button = QPushButton("Install temporary Lineage")
        install_button.clicked.connect(self.install)
        layout.addWidget(install_button)

        track_button = QPushButton("Track Lineage")
        track_button.clicked.connect(self.track_lineage)
        layout.addWidget(track_button)

        logout_button = QPushButton("Logout")
        logout_button.clicked.connect(self.logout)
        layout.addWidget(logout_button)

        wid = QWidget(self)
        self.setCentralWidget(wid)
        wid.setLayout(layout)

    def login(self):
        host = self.host_entry.text()
        dbname = self.dbname_entry.text()
        user = self.user_entry.text()
        password = self.password_entry.text()
        port = self.port_entry.text()

        self.selected_db = self.db_combo.currentText()
        if self.selected_db == "PostgreSQL":
            self.db_metadata = PostgresDatabaseManagement(host, dbname, user, password, port)
        elif self.selected_db == 'SQL Server':
            self.db_metadata = SQLServerDatabaseManagement(host, dbname, user, password, port)
        elif self.selected_db == "Oracle":
            self.db_metadata = OracleDatabaseManagement(host, port, dbname, user, password)
        try:
            self.db_metadata.connect()
            self.logged_in = True
            QMessageBox.information(self, "Success", "Connected")
            self.init_ui()
        except:
            QMessageBox.critical(self, "Error", "Failed to connect to the database.")

    def logout(self):
        if self.db_metadata:
            self.db_metadata.close()
            self.db_metadata = None
        self.logged_in = False
        self.init_ui()

    def track_lineage(self):
        if self.db_metadata:
            columns = self.db_metadata.fetch_table_metadata()
            constraints = self.db_metadata.fetch_table_constraints()
            views = self.db_metadata.fetch_view_dependencies()
            procedures = self.db_metadata.fetch_stored_procedures()
            operations = self.db_metadata.fetch_system_operations()
            if self.selected_db == "Oracle":
                data_lineage = DataLineageGraph(columns, constraints, views, procedures, operations, True)
            else:
                data_lineage = DataLineageGraph(columns, constraints, views, procedures, operations)
            data_lineage.draw_graph()
        else:
            QMessageBox.critical(self, "Error", "Not connected to any database.")
    
    def install(self):
        if self.db_metadata:
            try:
                self.db_metadata.create_system_operations_table()
                self.db_metadata.handle_create_table_as_function()
                self.db_metadata.create_table_as_trigger()
                self.db_metadata.handle_create_view_function()
                self.db_metadata.create_view_trigger()
                if self.selected_db == 'SQL Server':
                    self.db_metadata.create_temp_table_extended_event()
                QMessageBox.information(self, "Success", "Extension installed")
            except Exception as e:
                print(e)
                QMessageBox.critical(self, "Error", "Failed to install extension.")
        else:
            QMessageBox.critical(self, "Error", "Not connected to any database.")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = LineageTrackerApp()
    window.show()
    sys.exit(app.exec_())
