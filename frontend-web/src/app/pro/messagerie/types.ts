export type Message = {
  id: number;
  sender: 'doctor' | 'patient';
  content: string;
  time: string;
};

export type Conversation = {
  id: number;
  patientName: string;
  lastMessage: string;
  lastMessageTime: string;
  unreadCount: number;
  avatar: string;
  messages: Message[];
};
