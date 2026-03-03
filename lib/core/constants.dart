const String kBaseUrl = 'https://ticketingjtl.vercel.app';

const String kTokenKey = 'jwt_token';
const String kUserKey = 'auth_user';

// User roles
const String kRoleAdmin = 'ADMIN';
const String kRoleITStaff = 'IT_STAFF';
const String kRoleUser = 'USER';

// Ticket categories
const List<String> kTicketCategories = [
  'account-login',
  'hardware',
  'software',
  'network',
  'email',
  'printer',
  'other',
];

// Ticket priorities
const List<String> kTicketPriorities = ['low', 'medium', 'high', 'urgent'];

// Ticket statuses
const List<String> kTicketStatuses = [
  'open',
  'in-progress',
  'resolved',
  'closed',
];

// Machine importance levels
const List<String> kMachineImportance = ['low', 'medium', 'high', 'critical'];

// Machine statuses
const List<String> kMachineStatuses = [
  'pending',
  'approved',
  'in-progress',
  'resolved',
  'rejected',
];
