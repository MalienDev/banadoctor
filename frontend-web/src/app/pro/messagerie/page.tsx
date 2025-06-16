'use client';

import { useState, useMemo } from 'react';
import { Search, MessageSquare, Send, Paperclip, Smile } from 'lucide-react';
import { Conversation, Message } from './types';

const initialConversations: Conversation[] = [
  {
    id: 1,
    patientName: 'Jean Dupont',
    lastMessage: 'Est-ce que vous auriez un créneau demain après-midi ?',
    lastMessageTime: '10:25',
    unreadCount: 1,
    avatar: 'JD',
    messages: [
      { id: 1, sender: 'patient', content: 'Bonjour, je voudrais prendre rendez-vous pour une consultation.', time: '10:15' },
      { id: 2, sender: 'doctor', content: 'Bonjour, bien sûr. Pour quelle date souhaitez-vous un rendez-vous ?', time: '10:20' },
      { id: 3, sender: 'patient', content: 'Est-ce que vous auriez un créneau demain après-midi ?', time: '10:25' },
    ],
  },
  {
    id: 2,
    patientName: 'Marie Martin',
    lastMessage: 'Merci pour votre réponse',
    lastMessageTime: 'Hier',
    unreadCount: 0,
    avatar: 'MM',
    messages: [
        { id: 1, sender: 'patient', content: 'Merci pour votre réponse', time: 'Hier' },
    ],
  },
];

export default function MessageriePage() {
  const [conversations, setConversations] = useState<Conversation[]>(initialConversations);
  const [activeConversationId, setActiveConversationId] = useState<number | null>(1);
  const [newMessage, setNewMessage] = useState('');
  const [searchTerm, setSearchTerm] = useState('');

  const handleSendMessage = () => {
    if (!newMessage.trim() || !activeConversationId) return;

    const newMessageObj: Message = {
      id: Date.now(),
      sender: 'doctor',
      content: newMessage,
      time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
    };

    setConversations(prev =>
      prev.map(convo =>
        convo.id === activeConversationId
          ? { ...convo, messages: [...convo.messages, newMessageObj], lastMessage: newMessage, lastMessageTime: newMessageObj.time }
          : convo
      )
    );
    setNewMessage('');
  };

  const filteredConversations = useMemo(() => 
    conversations.filter(c => c.patientName.toLowerCase().includes(searchTerm.toLowerCase())),
    [conversations, searchTerm]
  );

  const activeConversation = conversations.find(c => c.id === activeConversationId);

  return (
    <div className="flex h-[calc(100vh-64px)] bg-white">
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
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
            />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto">
          {filteredConversations.map((convo) => (
            <div
              key={convo.id}
              className={`p-4 border-b border-gray-100 hover:bg-gray-50 cursor-pointer ${
                activeConversationId === convo.id ? 'bg-blue-50' : ''
              }`}
              onClick={() => setActiveConversationId(convo.id)}
            >
              <div className="flex items-center">
                <div className="h-10 w-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-medium mr-3">
                  {convo.avatar}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-center">
                    <h3 className="font-medium truncate">{convo.patientName}</h3>
                    <span className="text-xs text-gray-500">{convo.lastMessageTime}</span>
                  </div>
                  <p className="text-sm text-gray-500 truncate">{convo.lastMessage}</p>
                </div>
                {convo.unreadCount > 0 && (
                  <div className="ml-2 bg-blue-600 text-white text-xs font-medium rounded-full h-5 w-5 flex items-center justify-center">
                    {convo.unreadCount}
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
          <div className="p-4 border-b border-gray-200 flex items-center">
            <div className="h-10 w-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-medium mr-3">
              {activeConversation.avatar}
            </div>
            <div>
              <h2 className="font-medium">{activeConversation.patientName}</h2>
              <p className="text-sm text-gray-500">En ligne</p>
            </div>
          </div>

          <div className="flex-1 p-6 overflow-y-auto bg-gray-50">
            <div className="space-y-4">
              {activeConversation.messages.map((msg) => (
                <div key={msg.id} className={`flex ${msg.sender === 'doctor' ? 'justify-end' : 'justify-start'}`}>
                  <div className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${msg.sender === 'doctor' ? 'bg-blue-600 text-white rounded-br-none' : 'bg-white border border-gray-200 rounded-bl-none'}`}>
                    <p className="text-sm">{msg.content}</p>
                    <p className={`text-xs mt-1 text-right ${msg.sender === 'doctor' ? 'text-blue-200' : 'text-gray-400'}`}>
                      {msg.time}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="p-4 border-t border-gray-200 bg-white">
            <div className="flex items-center">
              <button className="p-2 text-gray-500 hover:text-gray-700"><Paperclip className="h-5 w-5" /></button>
              <input
                type="text"
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                placeholder="Écrivez votre message..."
                className="flex-1 border-0 focus:ring-0 focus:outline-none px-4 py-2"
                onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
              />
              <button className="p-2 text-gray-500 hover:text-gray-700"><Smile className="h-5 w-5" /></button>
              <button
                className="ml-2 p-2 bg-blue-600 text-white rounded-full hover:bg-blue-700 disabled:bg-blue-300"
                onClick={handleSendMessage}
                disabled={!newMessage.trim()}
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
            <p className="text-gray-500">Aucune conversation correspondante à votre recherche.</p>
          </div>
        </div>
      )}
    </div>
  );
}
