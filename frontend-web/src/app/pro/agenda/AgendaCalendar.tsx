'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { format, startOfWeek, addDays, startOfDay, getDay, isSameDay, parseISO } from 'date-fns';
import { fr } from 'date-fns/locale/fr';
import { Label } from "@radix-ui/react-label";
import { Input } from '@geist-ui/core';
import { getDoctorAvailability, addDoctorAvailability, deleteDoctorAvailability, Availability } from '@/lib/api';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { Switch } from '@/components/ui/switch';

// Create a custom formatter with French locale
const formatFr = (date: Date, formatStr: string) => format(date, formatStr, { locale: fr });

// Generate time slots for a given day with configurable interval
const generateTimeSlots = (date: Date, intervalMinutes = 30): Date[] => {
  const slots: Date[] = [];
  const startHour = 8;
  const endHour = 19;
  const slotsPerHour = 60 / intervalMinutes;
  
  for (let hour = startHour; hour < endHour; hour++) {
    for (let i = 0; i < slotsPerHour; i++) {
      const minutes = i * intervalMinutes;
      slots.push(new Date(startOfDay(date).setHours(hour, minutes, 0, 0)));
    }
  }
  return slots;
};

// Helper to get the key for the availability map
const getAvailabilityKey = (day: Date, hour: number): string => {
  return `${format(day, 'yyyy-MM-dd')}:${hour}`;
};

type ViewMode = 'week' | 'day';

export default function AgendaCalendar() {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [viewMode, setViewMode] = useState<ViewMode>('week');
  const [availability, setAvailability] = useState<Record<string, Availability>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [isRecurring, setIsRecurring] = useState(true);
  const [newSlot, setNewSlot] = useState<{
    start: Date | null;
    end: Date | null;
    dayOfWeek: number | null;
  }>({ start: null, end: null, dayOfWeek: null });

  const weekStartsOn = 1; // Monday
  const week = React.useMemo(() => {
    return Array.from({ length: 7 }).map((_, i) => addDays(startOfWeek(currentDate, { weekStartsOn }), i));
  }, [currentDate]);
  
  const timeSlots = React.useMemo(() => generateTimeSlots(currentDate, 30), [currentDate]);
  
  // Group availability by day for easier rendering
  const availabilityByDay = React.useMemo(() => {
    const result: Record<string, Availability[]> = {};
    Object.values(availability).forEach(slot => {
      const day = week[slot.day_of_week];
      if (day) {
        const dayKey = format(day, 'yyyy-MM-dd');
        if (!result[dayKey]) {
          result[dayKey] = [];
        }
        result[dayKey].push(slot);
      }
    });
    return result;
  }, [availability, week]);

  // Fetch availability from the backend
  const fetchAvailability = useCallback(async () => {
    setIsLoading(true);
    try {
      const data = await getDoctorAvailability();
      const availabilityMap: Record<string, Availability> = {};
      
      data.forEach(slot => {
        const dayInWeek = week.find(d => (getDay(d) + 6) % 7 === slot.day_of_week);
        if (dayInWeek) {
            const startHour = parseInt(slot.start_time.split(':')[0], 10);
            const key = getAvailabilityKey(dayInWeek, startHour);
            availabilityMap[key] = slot;
        }
      });

      setAvailability(availabilityMap);
    } catch (error) {
      console.error('Failed to fetch availability:', error);
      toast.error('Erreur lors de la récupération des disponibilités.');
    } finally {
      setIsLoading(false);
    }
  }, [JSON.stringify(week)]);

  useEffect(() => {
    fetchAvailability();
  }, [fetchAvailability]);

  const handleToggleAvailability = useCallback(async (day: Date, hour: number) => {
    const key = getAvailabilityKey(day, hour);
    const existingSlot = availability[key];

    try {
      if (existingSlot) {
        await deleteDoctorAvailability(existingSlot.id);
        setAvailability(prev => {
          const newAvail = { ...prev };
          delete newAvail[key];
          return newAvail;
        });
        toast.success('Créneau de disponibilité supprimé.');
      } else {
        const dayOfWeek = (getDay(day) + 6) % 7;
        const startTime = `${String(hour).padStart(2, '0')}:00`;
        const endTime = `${String(hour + 1).padStart(2, '0')}:00`;
        
        // Check if slot already exists in the database
        const existingSlots = await getDoctorAvailability();
        const slotExists = existingSlots.some(slot => 
          slot.day_of_week === dayOfWeek && 
          slot.start_time === startTime && 
          slot.end_time === endTime
        );
        
        if (slotExists) {
          toast.error('Ce créneau de disponibilité existe déjà.');
          return;
        }
        
        const newSlotData = {
          day_of_week: dayOfWeek,
          start_time: startTime,
          end_time: endTime,
          is_available: true,
        };
        const newSlot = await addDoctorAvailability(newSlotData);
        setAvailability(prev => ({ ...prev, [key]: newSlot }));
        toast.success('Créneau de disponibilité ajouté.');
      }
    } catch (error) {
      console.error('Failed to update availability:', error);
      toast.error('Erreur lors de la mise à jour des disponibilités.');
    }
  }, [availability]);

  const renderTimeSlots = (day: Date) => {
    const dayKey = format(day, 'yyyy-MM-dd');
    const daySlots = availabilityByDay[dayKey] || [];
    
    return timeSlots.map((timeSlot, idx) => {
      const slotHour = timeSlot.getHours();
      const slotMinute = timeSlot.getMinutes();
      const slotKey = `${dayKey}-${String(slotHour).padStart(2, '0')}:${String(slotMinute).padStart(2, '0')}`;
      
      // Check if this time slot is available
      const isAvailable = daySlots.some(slot => {
        const [startHour, startMinute] = slot.start_time.split(':').map(Number);
        const [endHour, endMinute] = slot.end_time.split(':').map(Number);
        
        const slotStart = slotHour * 60 + slotMinute;
        const slotEnd = slotStart + 30; // 30-minute slots
        const availabilityStart = startHour * 60 + startMinute;
        const availabilityEnd = endHour * 60 + endMinute;
        
        return slotStart >= availabilityStart && slotEnd <= availabilityEnd;
      });

      return (
        <div
          key={slotKey}
          onClick={() => handleTimeSlotClick(day, timeSlot)}
          className={`h-8 border-b border-r cursor-pointer transition-colors ${
            isAvailable ? 'bg-green-100 hover:bg-green-200' : 'bg-gray-50 hover:bg-gray-100'
          }`}
        ></div>
      );
    });
  };

  const handleTimeSlotClick = (day: Date, time: Date) => {
    // If we're in the middle of creating a new slot
    if (newSlot.start && !newSlot.end) {
      const endTime = new Date(time);
      if (endTime > newSlot.start) {
        setNewSlot({
          ...newSlot,
          end: endTime,
          dayOfWeek: (getDay(day) + 6) % 7 // Convert to 0-6 (Mon-Sun)
        });
      }
    } else {
      // Start a new slot
      setNewSlot({
        start: new Date(time),
        end: null,
        dayOfWeek: (getDay(day) + 6) % 7
      });
    }
  };

  const handleSaveSlot = async () => {
    if (!newSlot.start || !newSlot.end || newSlot.dayOfWeek === null) return;

    try {
      const startTime = format(newSlot.start, 'HH:mm');
      const endTime = format(newSlot.end, 'HH:mm');
      
      if (isRecurring) {
        // Apply to all weeks on the same day of week
        const newSlots = [];
        for (let i = 0; i < 4; i++) { // Next 4 weeks
          const targetDate = addDays(newSlot.start, i * 7);
          const slotData = {
            day_of_week: newSlot.dayOfWeek,
            start_time: startTime,
            end_time: endTime,
            is_available: true,
            date: format(targetDate, 'yyyy-MM-dd')
          };
          const slot = await addDoctorAvailability(slotData);
          newSlots.push(slot);
        }
        toast.success('Créneaux récurrents ajoutés avec succès');
      } else {
        // Single slot
        const slotData = {
          day_of_week: newSlot.dayOfWeek,
          start_time: startTime,
          end_time: endTime,
          is_available: true,
          date: format(newSlot.start, 'yyyy-MM-dd')
        };
        await addDoctorAvailability(slotData);
        toast.success('Créneau ajouté avec succès');
      }
      
      setNewSlot({ start: null, end: null, dayOfWeek: null });
      fetchAvailability();
    } catch (error) {
      console.error('Error saving slot:', error);
      toast.error('Erreur lors de l\'ajout du créneau');
    }
  };

  return (
    <div className="bg-white rounded-xl shadow p-6 relative">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-semibold">Vos disponibilités</h2>
        <div className="flex items-center space-x-4">
          <div className="flex items-center space-x-2">
            <Switch 
              id="recurring-mode" 
              checked={isRecurring} 
              onCheckedChange={setIsRecurring} 
            />
            <Label htmlFor="recurring-mode">Récurrent</Label>
          </div>
          <Button 
            variant="outline" 
            onClick={() => setViewMode(viewMode === 'week' ? 'day' : 'week')}
          >
            {viewMode === 'week' ? 'Vue jour' : 'Vue semaine'}
          </Button>
        </div>
      </div>

      <div className="flex items-center space-x-4 mb-4">
        <Button
          variant="outline"
          onClick={() => setCurrentDate(addDays(currentDate, viewMode === 'week' ? -7 : -1))}
        >
          Précédent
        </Button>
        <h3 className="text-lg font-medium">
          {viewMode === 'week' 
            ? `${format(week[0], 'd MMMM yyyy')} - ${format(week[6], 'd MMMM yyyy')}`
            : format(selectedDate, 'EEEE d MMMM yyyy', { locale: fr })}
        </h3>
        <Button
          variant="outline"
          onClick={() => setCurrentDate(addDays(currentDate, viewMode === 'week' ? 7 : 1))}
        >
          Suivant
        </Button>
      </div>

      {newSlot.start && (
        <div className="mb-4 p-4 bg-blue-50 rounded-lg">
          <h4 className="font-medium mb-2">Nouveau créneau</h4>
          <div className="flex items-center space-x-4">
            <div>
              <Label>Début</Label>
              <Input

                value={newSlot.start ? format(newSlot.start, 'HH:mm') : ''}
                onChange={(e) => {
                  const [hours, minutes] = e.target.value.split(':').map(Number);
                  if (newSlot.start && !isNaN(hours) && !isNaN(minutes)) {
                    const newDate = new Date(newSlot.start);
                    newDate.setHours(hours, minutes);
                    setNewSlot({ ...newSlot, start: newDate });
                  }
                } }
                placeholder="HH:MM"
                width="100%" crossOrigin={undefined} onPointerEnterCapture={undefined} onPointerLeaveCapture={undefined}              />
            </div>
            {newSlot.end && (
              <>
                <div>
                  <Label>Fin</Label>
                  <Input
    
                    value={newSlot.end ? format(newSlot.end, 'HH:mm') : ''}
                    onChange={(e) => {
                      const [hours, minutes] = e.target.value.split(':').map(Number);
                      if (!isNaN(hours) && !isNaN(minutes)) {
                        const baseDate = newSlot.end || newSlot.start;
                        if (baseDate) {
                          const newDate = new Date(baseDate);
                          newDate.setHours(hours, minutes);
                          setNewSlot({ ...newSlot, end: newDate });
                        }
                      }
                    } }
                    placeholder="HH:MM"
                    width="100%" crossOrigin={undefined} onPointerEnterCapture={undefined} onPointerLeaveCapture={undefined}                  />
                </div>
                <Button onClick={handleSaveSlot} className="mt-6">
                  Enregistrer
                </Button>
              </>
            )}
          </div>
        </div>
      )}

      <div className="overflow-x-auto">
        <div className="grid grid-cols-8 text-center text-sm min-w-max">
          <div className="h-16"></div> {/* Corner offset */}
          {week.map(day => (
            <div key={day.toString()} className="font-semibold capitalize">
              {formatFr(day, 'EEE')}
              <div className="text-2xl font-bold">{formatFr(day, 'd')}</div>
            </div>
          ))}

          <div className="col-span-8 grid grid-cols-8">
            <div className="col-span-1">
              {timeSlots.map((time, idx) => (
                <div key={idx} className="h-8 text-xs text-right pr-2 text-gray-500">
                  {idx % 2 === 0 ? format(time, 'HH:mm') : ''}
                </div>
              ))}
            </div>
            
            {week.map(day => (
              <div key={day.toString()} className="col-span-1 border-l">
                {renderTimeSlots(day)}
              </div>
            ))}
          </div>
        </div>
      </div>

      {isLoading && (
        <div className="absolute inset-0 bg-white bg-opacity-50 flex items-center justify-center rounded-xl">
          <p>Chargement...</p>
        </div>
      )}
    </div>
  );
}
