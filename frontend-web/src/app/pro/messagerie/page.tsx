'use client';

import { useState } from 'react';
import { Search, MessageSquare, User, Send, Paperclip, Smile, Bell } from 'lucide-react';

type Message = {
  id: number;
  sender: string;
  content: string;
  time: string;
  unread: boolean;
};

type Conversation = {
  id: number;
  patient: string;
  lastMessage: string;
  time: string;
  unread: number;
  avatar: string;
};

export default function MessageriePage() {
  const [activeConversation, setActiveConversation] = useState<number | null>(1);
  const [message, setMessage] = useState('');

  // Sample data - replace with actual data fetching
  const conversations: Conversation[] = [
    {
      id: 1,
      patient: 'Jean Dupont',
      lastMessage: 'Bonjour, je voudrais prendre rendez-vous...',
      time: '10:30',
      unread: 2,
      avatar: 'JD',
    },
    {
      id: 2,
      patient: 'Marie Martin',
      lastMessage: 'Merci pour votre réponse',
      time: 'Hier',
      unread: 0,
      avatar: 'MM',
    },
    {
      id: 3,
      patient: 'Pierre Durand',
      lastMessage: 'À quelle heure est mon RDV demain ?',
      time: 'Lun',
      unread: 0,
      avatar: 'PD',
    },
  ];

  // Sample messages - replace with actual data fetching
  const messages: Record<number, Message[]> = {
    1: [
      {
        id: 1,
        sender: 'Jean Dupont',
        content: 'Bonjour, je voudrais prendre rendez-vous pour une consultation.',
        time: '10:15',
        unread: false,
      },
      {
        id: 2,
        sender: 'Vous',
        content: 'Bonjour, bien sûr. Pour quelle date souhaitez-vous un rendez-vous ?',
        time: '10:20',
        unread: false,
      },
      {
        id: 3,
        sender: 'Jean Dupont',
        content: 'Est-ce que vous auriez un créneau demain après-midi ?',
        time: '10:25',
        unread: true,
      },
    ],
  };

  const activeMessages = activeConversation ? messages[activeConversation] || [] : [];

  return (
    <div className="flex h-[calc(100vh-64px)]">
      {/* Sidebar */}
      <div className="w-96 border-r border-gray-200 flex flex-col">
        <div className="p-4 border-b border-gray-200">
          <h1 className="text-xl font-bold mb-4">Messages</h1>
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Rechercher une conversation..."
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto">
          {conversations.map((conversation) => (
            <div
              key={conversation.id}
              className={`p-4 border-b border-gray-100 hover:bg-gray-50 cursor-pointer ${
                activeConversation === conversation.id ? 'bg-blue-50' : ''
              }`}
              onClick={() => setActiveConversation(conversation.id)}
            >
              <div className="flex items-center">
                <div className="h-10 w-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-medium mr-3">
                  {conversation.avatar}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-center">
                    <h3 className="font-medium truncate">{conversation.patient}</h3>
                    <span className="text-xs text-gray-500">{conversation.time}</span>
                  </div>
                  <p className="text-sm text-gray-500 truncate">{conversation.lastMessage}</p>
                </div>
                {conversation.unread > 0 && (
                  <div className="ml-2 bg-blue-600 text-white text-xs font-medium rounded-full h-5 w-5 flex items-center justify-center">
                    {conversation.unread}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Chat area */}
      {activeConversation ? (
        <div className="flex-1 flex flex-col">
          {/* Chat header */}
          <div className="p-4 border-b border-gray-200 flex items-center">
            <div className="h-10 w-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-medium mr-3">
              {conversations.find(c => c.id === activeConversation)?.avatar}
            </div>
            <div>
              <h2 className="font-medium">
                {conversations.find(c => c.id === activeConversation)?.patient}
              </h2>
              <p className="text-sm text-gray-500">En ligne</p>
            </div>
          </div>

          {/* Messages */}
          <div className="flex-1 p-4 overflow-y-auto bg-gray-50">
            <div className="space-y-4">
              {activeMessages.map((msg) => (
                <div
                  key={msg.id}
                  className={`flex ${
                    msg.sender === 'Vous' ? 'justify-end' : 'justify-start'
                  }`}
                >
                  <div
                    className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                      msg.sender === 'Vous'
                        ? 'bg-blue-600 text-white rounded-br-none'
                        : 'bg-white border border-gray-200 rounded-bl-none'
                    }`}
                  >
                    <p className="text-sm">{msg.content}</p>
                    <p
                      className={`text-xs mt-1 text-right ${
                        msg.sender === 'Vous' ? 'text-blue-200' : 'text-gray-400'
                      }`}
                    >
                      {msg.time}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Message input */}
          <div className="p-4 border-t border-gray-200">
            <div className="flex items-center">
              <button className="p-2 text-gray-500 hover:text-gray-700">
                <Paperclip className="h-5 w-5" />
              </button>
              <input
                type="text"
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="Écrivez votre message..."
                className="flex-1 border-0 focus:ring-0 focus:outline-none px-4 py-2"
                onKeyPress={(e) => {
                  if (e.key === 'Enter' && message.trim()) {
                    // Handle send message
                    setMessage('');
                  }
                }}
              />
              <button className="p-2 text-gray-500 hover:text-gray-700">
                <Smile className="h-5 w-5" />
              </button>
              <button
                className="ml-2 p-2 bg-blue-600 text-white rounded-full hover:bg-blue-700"
                onClick={() => {
                  if (message.trim()) {
                    // Handle send message
                    setMessage('');
                  }
                }}
              >
                <Send className="h-5 w-5" />
              </button>
            </div>
          </div>
        </div>
      ) : (
        <div className="flex-1 flex items-center justify-center bg-gray-50">
          <div className="text-center p-8">
            <MessageSquare className="h-12 w-12 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-1">Sélectionnez une conversation</h3>
            <p className="text-gray-500">Choisissez une conversation ou commencez-en une nouvelle</p>
          </div>
        </div>
      )}
    </div>
  );
}
