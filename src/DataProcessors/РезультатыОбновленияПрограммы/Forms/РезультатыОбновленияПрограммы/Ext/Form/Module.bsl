﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастройкиПодсистемы = ОбновлениеИнформационнойБазыСлужебный.НастройкиПодсистемы();
	ТекстПодсказки      = НастройкиПодсистемы.ПоясненияДляРезультатовОбновления;
	
	Если Не ПустаяСтрока(ТекстПодсказки) Тогда
		Элементы.ПодсказкаГдеНайтиЭтуФорму.Заголовок = ТекстПодсказки;
	КонецЕсли;
	
	Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		
		Элементы.ГруппаПодсказкаПроПериодНаименьшейАктивностиПользователей.Видимость = Ложь;
		Элементы.ПодсказкаГдеНайтиЭтуФорму.Заголовок = 
			НСтр("ru = 'Ход обработки данных версии программы можно также проконтролировать из раздела
		               |""Информация"" на рабочем столе, команда ""Описание изменений программы"".'");
		
	КонецЕсли;
	
	// Зачитываем значение констант.
	ПолучитьКоличествоПотоковОбновленияИнформационнойБазы();
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	ПриоритетОбновления = ?(СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Свойство("ФорсироватьОбновление"), "ОбработкаДанных", "РаботаПользователей");
	ВремяОкончанияОбновления = СведенияОбОбновлении.ВремяОкончанияОбновления;
	
	ВремяНачалаОтложенногоОбновления = СведенияОбОбновлении.ВремяНачалаОтложенногоОбновления;
	ВремяОкончаниеОтложенногоОбновления = СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления;
	
	ИБФайловая = ОбщегоНазначения.ИнформационнаяБазаФайловая();
	
	Если ЗначениеЗаполнено(ВремяОкончанияОбновления) Тогда
		Элементы.ИнформацияОбновлениеЗавершено.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			Элементы.ИнформацияОбновлениеЗавершено.Заголовок,
			Метаданные.Версия,
			Формат(ВремяОкончанияОбновления, "ДЛФ=D"),
			Формат(ВремяОкончанияОбновления, "ДЛФ=T"),
			СведенияОбОбновлении.ПродолжительностьОбновления);
	Иначе
		ЗаголовокОбновлениеЗавершено = НСтр("ru = 'Версия программы успешно обновлена на версию %1'");
		Элементы.ИнформацияОбновлениеЗавершено.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ЗаголовокОбновлениеЗавершено, Метаданные.Версия);
	КонецЕсли;
	
	Если СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления = Неопределено Тогда
		
		Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
			Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.СтатусОбновленияДляПользователя;
		Иначе
			
			Если Не ИБФайловая И СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно = Неопределено Тогда
				Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВыполняется;
				ПроверитьВыполнениеОтложенногоОбновления(СведенияОбОбновлении);
			Иначе
				Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВФайловойБазе;
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		ТекстСообщения = СообщениеОРезультатахОбновления();
		Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеЗавершено;
		
		ШаблонЗаголовка = НСтр("ru = 'Дополнительные процедуры обработки данных завершены %1 в %2'");
		Элементы.ИнформацияОтложенноеОбновлениеЗавершено.Заголовок = 
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗаголовка, 
			Формат(СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления, "ДЛФ=D"),
			Формат(СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления, "ДЛФ=T"));
		
	КонецЕсли;
	
	УстановитьВидимостьКоличестваПотоковОбновленияИнформационнойБазы();
	
	Если Не ИБФайловая Тогда
		ОбновлениеЗавершено = Ложь;
		ОбновитьИнформациюОХодеОбновления(ОбновлениеЗавершено);
		УстановитьДоступностьКоличестваПотоковОбновленияИнформационнойБазы(ЭтотОбъект);
		
		Если ОбновлениеЗавершено Тогда
			ОбновитьСтраницуОбновлениеЗавершено(СведенияОбОбновлении);
			Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеЗавершено;
		КонецЕсли;
		
	Иначе
		ОбновитьИнформациюПоПроблемам();
		Элементы.ИнформацияСтатусОбновления.Видимость = Ложь;
		Элементы.ИзменитьРасписание.Видимость         = Ложь;
	КонецЕсли;
	
	Если Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		
		Если ОбщегоНазначения.РазделениеВключено() Тогда
			Элементы.ГруппаНастройкаРасписания.Видимость = Ложь;
		Иначе
			ОтборЗаданий = Новый Структура;
			ОтборЗаданий.Вставить("Метаданные", Метаданные.РегламентныеЗадания.ОтложенноеОбновлениеИБ);
			Задания = РегламентныеЗаданияСервер.НайтиЗадания(ОтборЗаданий);
			Для Каждого Задание Из Задания Цикл
				Расписание = Задание.Расписание;
				Прервать;
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Элементы.ГиперссылкаОсновноеОбновление.Видимость = Ложь;
		Элементы.ГруппаПриоритет.Видимость               = Ложь;
	КонецЕсли;
	
	ОбработатьРезультатОбновленияНаСервере();
	
	СкрытьЛишниеГруппыНаФорме(Параметры.ОткрытиеИзПанелиАдминистрирования, СведенияОбОбновлении);
	
	Элементы.ОткрытьСписокОтложенныхОбработчиков.Заголовок = ТекстСообщения;
	Элементы.ЗаголовокИнформации.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Выполняются дополнительные процедуры обработки данных на версию %1
			|Работа с этими данными временно ограничена.'"), Метаданные.Версия);
	
	Элементы.ФормаПерезапуститьОтложенноеОбновление.Видимость = Не ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ()
		И ЕстьОбработчикиСПараллельнымРежимомВыполнения()
		И Пользователи.ЭтоПолноправныйПользователь();
	
	ПодсказкаПроблемСДанными = НСтр("ru = 'Проблемы с данными могут мешать их обработке при переходе на новую версию.
		|Если выполнение дополнительных процедур обработки данных завершилось с ошибкой, то необходимо:
		|  • перейти к списку проблем и исправить их согласно рекомендации в отчете;
		|  • продолжить выполнение дополнительных процедур обработки данных, для чего необходимо перейти по гиперссылке <b>Не все процедуры удалось выполнить ...</b> и нажать на кнопку <b>Запустить</b> внизу формы.'");
	ПодсказкаПроблемСДанными = СтроковыеФункции.ФорматированнаяСтрока(ПодсказкаПроблемСДанными);
	Элементы.ПроблемыСДанными.РасширеннаяПодсказка.Заголовок = ПодсказкаПроблемСДанными;
	Элементы.ПроблемыСДаннымиЗавершено.РасширеннаяПодсказка.Заголовок = ПодсказкаПроблемСДанными;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
#Если МобильныйКлиент Тогда
	ЭтотОбъект.ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Нет;
#КонецЕсли
	
	Если Не ИБФайловая Тогда
		ПодключитьОбработчикОжидания("ПроверитьСтатусВыполненияОбработчиков", 15);
	КонецЕсли;
	
	ОбработатьРезультатОбновленияНаКлиенте();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ОтложенноеОбновление" Тогда
		
		Если Не ИБФайловая Тогда
			Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВыполняется;
		КонецЕсли;
		
		ОбновлениеЗавершеноУспешно = Ложь;
		ПодключитьОбработчикОжидания("ЗапуститьОтложенноеОбновление", 0.5, Истина);
	ИначеЕсли ИмяСобытия = "ОтложенноеОбновлениеПерезапущено" Тогда
		Если ИБФайловая Тогда
			Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВФайловойБазе;
		Иначе
			Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВыполняется;
		КонецЕсли;
		ОбновлениеЗавершеноУспешно = Ложь;
		ПроверитьСтатусВыполненияОбработчиков();
		ПодключитьОбработчикОжидания("ПроверитьСтатусВыполненияОбработчиков", 15);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияСтатусОбновленияНажатие(Элемент)
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.ОтложенныеОбработчики");
КонецПроцедуры

&НаКлиенте
Процедура ГиперссылкаОсновноеОбновлениеНажатие(Элемент)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ДатаНачала", ВремяНачалаОтложенногоОбновления);
	Если ВремяОкончаниеОтложенногоОбновления <> Неопределено Тогда
		ПараметрыФормы.Вставить("ДатаОкончания", ВремяОкончаниеОтложенногоОбновления);
	КонецЕсли;
	
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ПараметрыФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияОшибкаОбновленияОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрыФормы = Новый Структура;
	
	СписокПриложений = Новый Массив;
	СписокПриложений.Добавить("COMConnection");
	СписокПриложений.Добавить("Designer");
	СписокПриложений.Добавить("1CV8");
	СписокПриложений.Добавить("1CV8C");
	
	ПараметрыФормы.Вставить("Пользователь", ИмяПользователя());
	ПараметрыФормы.Вставить("ИмяПриложения", СписокПриложений);
	
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ПараметрыФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриоритетОбновленияПриИзменении(Элемент)
	
	УстановитьПриоритетОбновления();
	УстановитьДоступностьКоличестваПотоковОбновленияИнформационнойБазы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура КоличествоПотоковОбновленияИнформационнойБазыПриИзменении(Элемент)
	
	УстановитьКоличествоПотоковОбновленияИнформационнойБазы();
	
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияИсправленияУстановленыОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ПоказатьУстановленныеИсправления();
КонецПроцедуры

&НаКлиенте
Процедура ПояснениеОбновлениеНеВыполняетсяОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	Если НавигационнаяСсылкаФорматированнойСтроки = "ПроверитьБлокировку" Тогда
		Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей") Тогда
			МодульСоединенияИБКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("СоединенияИБКлиент");
			МодульСоединенияИБКлиент.ПриОткрытииФормыБлокировкиРаботыПользователей();
		КонецЕсли;
	ИначеЕсли НавигационнаяСсылкаФорматированнойСтроки = "Включить" Тогда
		ВключитьРегламентноеЗадание();
		ТекстСообщения = НСтр("ru = 'Задание включено. Статус обновления скоро обновится.'");
		ПоказатьПредупреждение(, ТекстСообщения);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыполнитьОбновление(Команда)
	
	Если Не ИБФайловая Тогда
		Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВыполняется;
	КонецЕсли;
	
	ПодключитьОбработчикОжидания("ЗапуститьОтложенноеОбновление", 0.5, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьСписокОтложенныхОбработчиков(Команда)
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.ОтложенныеОбработчики");
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьРасписание(Команда)
	
	Диалог = Новый ДиалогРасписанияРегламентногоЗадания(Расписание);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ИзменитьРасписаниеПослеУстановкиРасписания", ЭтотОбъект);
	Диалог.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияДляТехническойПоддержки(Команда)
	
	Если Не ПустаяСтрока(КаталогСкрипта) Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("НачатьПоискФайловЗавершение", ЭтотОбъект);
		НачатьПоискФайлов(ОписаниеОповещения, КаталогСкрипта, "log*.txt");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НачатьПоискФайловЗавершение(МассивФайлов, ДополнительныеПараметры) Экспорт
	Если МассивФайлов.Количество() > 0 Тогда
		ФайлЖурнала = МассивФайлов[0];
		ФайловаяСистемаКлиент.ОткрытьФайл(ФайлЖурнала.ПолноеИмя);
	Иначе
		// Если лога нет, то открываем временный каталог скрипта обновления.
		ФайловаяСистемаКлиент.ОткрытьПроводник(КаталогСкрипта);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПроблемныеСитуацииНажатие(Элемент)
	Уровни = Новый Массив;
	Уровни.Добавить("Ошибка");
	Уровни.Добавить("Предупреждение");
	
	ОтборЖурнала = Новый Структура;
	ОтборЖурнала.Вставить("ДатаНачала", ВремяНачалаОтложенногоОбновления);
	ОтборЖурнала.Вставить("Уровень", Уровни);
	ОтборЖурнала.Вставить("СобытиеЖурналаРегистрации", НСтр("ru = 'Обновление информационной базы'", ОбщегоНазначенияКлиент.КодОсновногоЯзыка()));
	ЖурналРегистрацииКлиент.ОткрытьЖурналРегистрации(ОтборЖурнала, ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ПерезапуститьОтложенноеОбновление(Команда)
	ОткрытьФорму("РегистрСведений.ОбработчикиОбновления.Форма.ПерезапускОтложенногоОбновления");
КонецПроцедуры

&НаКлиенте
Процедура ПроблемыСДаннымиНажатие(Элемент)
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.КонтрольВеденияУчета") Тогда
		МодульКонтрольВеденияУчетаКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("КонтрольВеденияУчетаКлиент");
		МодульКонтрольВеденияУчетаКлиент.ОткрытьОтчетПоПроблемам("ОбновлениеВерсииИБ", Ложь);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СкрытьЛишниеГруппыНаФорме(ОткрытиеИзПанелиАдминистрирования, Сведения)
	
	ЭтоПолноправныйПользователь = Пользователи.ЭтоПолноправныйПользователь(, Истина);
	
	Если Не ЭтоПолноправныйПользователь Или ОткрытиеИзПанелиАдминистрирования Тогда
		КлючСохраненияПоложенияОкна = "ФормаДляОбычногоПользователя";
		
		Элементы.ПодсказкаГдеНайтиЭтуФорму.Видимость = Ложь;
		Элементы.ГиперссылкаОсновноеОбновление.Видимость = ПравоДоступа("Просмотр", Метаданные.Обработки.ЖурналРегистрации);
		
	Иначе
		КлючСохраненияПоложенияОкна = "ФормаДляАдминистратора";
	КонецЕсли;
	
	Если ЭтоПолноправныйПользователь
		И ЗначениеЗаполнено(Сведения.ВерсияУдалениеПатчей)
		И Метаданные.Версия = Сведения.ВерсияУдалениеПатчей Тогда
		Элементы.ГруппаИнформацияОбУдаленииПатчей.Видимость = Истина;
		КлючСохраненияПоложенияОкна = "ПредупреждениеПоУдалениюПатчей";
	Иначе
		Элементы.ГруппаИнформацияОбУдаленииПатчей.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПриоритетОбновления()
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		Блокировка.Добавить("Константа.СведенияОбОбновленииИБ");
		Блокировка.Заблокировать();
		
		СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
		Если ПриоритетОбновления = "ОбработкаДанных" Тогда
			СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Вставить("ФорсироватьОбновление");
		Иначе
			СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Удалить("ФорсироватьОбновление");
		КонецЕсли;
		
		ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьКоличествоПотоковОбновленияИнформационнойБазы()
	
	Константы.КоличествоПотоковОбновленияИнформационнойБазы.Установить(КоличествоПотоковОбновленияИнформационнойБазы);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьОтложенноеОбновление()
	
	ВыполнитьОбновлениеНаСервере();
	Если Не ИБФайловая Тогда
		ПроверитьСтатусВыполненияОбработчиков();
		ПодключитьОбработчикОжидания("ПроверитьСтатусВыполненияОбработчиков", 15);
		Возврат;
	КонецЕсли;
	
	Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеЗавершено;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьСтатусВыполненияОбработчиков()
	
	ОбновлениеЗавершено = Ложь;
	ПроверитьСтатусВыполненияОбработчиковНаСервере(ОбновлениеЗавершено);
	Если ОбновлениеЗавершено Тогда
		Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеЗавершено;
		ОтключитьОбработчикОжидания("ПроверитьСтатусВыполненияОбработчиков")
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьСтатусВыполненияОбработчиковНаСервере(ОбновлениеЗавершено)
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	Если СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления <> Неопределено Тогда
		ОбновлениеЗавершено = Истина;
	Иначе
		ОбновитьИнформациюОХодеОбновления(ОбновлениеЗавершено);
	КонецЕсли;
	
	Если ОбновлениеЗавершено = Истина Тогда
		ОбновитьСтраницуОбновлениеЗавершено(СведенияОбОбновлении);
		ОбновитьИнформациюПоПроблемам();
	Иначе
		ПроверитьВыполнениеОтложенногоОбновления(СведенияОбОбновлении);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ВыполнитьОбновлениеНаСервере()
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	
	СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно = Неопределено;
	СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления = Неопределено;
	
	СброситьСтатусОбработчиков(Перечисления.СтатусыОбработчиковОбновления.Ошибка);
	СброситьСтатусОбработчиков(Перечисления.СтатусыОбработчиковОбновления.Выполняется);
	
	ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
	
	Если Не ИБФайловая Тогда
		ВключитьРегламентноеЗадание();
		Возврат;
	КонецЕсли;
	
	ОбновлениеИнформационнойБазыСлужебный.ВыполнитьОтложенноеОбновлениеСейчас(Неопределено);
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	ОбновитьСтраницуОбновлениеЗавершено(СведенияОбОбновлении);
	
КонецПроцедуры

&НаСервере
Процедура СброситьСтатусОбработчиков(Статус)
	
	// АПК:1327-выкл нет конкурентной работы с регистром
	// АПК:1328-выкл нет конкурентной работы с регистром
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Статус", Статус);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ОбработчикиОбновления.ИмяОбработчика КАК ИмяОбработчика
		|ИЗ
		|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновления
		|ГДЕ
		|	ОбработчикиОбновления.Статус = &Статус";
	Обработчики = Запрос.Выполнить().Выгрузить();
	Для Каждого Обработчик Из Обработчики Цикл
		НаборЗаписей = РегистрыСведений.ОбработчикиОбновления.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.ИмяОбработчика.Установить(Обработчик.ИмяОбработчика);
		НаборЗаписей.Прочитать();
		
		Запись = НаборЗаписей[0];
		Запись.ЧислоПопыток = 0;
		Запись.Статус = Перечисления.СтатусыОбработчиковОбновления.НеВыполнялся;
		СтатистикаВыполнения = Запись.СтатистикаВыполнения.Получить();
		СтатистикаВыполнения.Вставить("КоличествоЗапусков", 0);
		Запись.СтатистикаВыполнения = Новый ХранилищеЗначения(СтатистикаВыполнения);
		
		НаборЗаписей.Записать();
	КонецЦикла;
	// АПК:1327-вкл
	// АПК:1328-вкл
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСтраницуОбновлениеЗавершено(СведенияОбОбновлении)
	
	ШаблонЗаголовка = НСтр("ru = 'Дополнительные процедуры обработки данных завершены %1 в %2'");
	ТекстСообщения = СообщениеОРезультатахОбновления();
	
	Элементы.ИнформацияОтложенноеОбновлениеЗавершено.Заголовок = 
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗаголовка, 
			Формат(СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления, "ДЛФ=D"),
			Формат(СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления, "ДЛФ=T"));
	
	Элементы.ОткрытьСписокОтложенныхОбработчиков.Заголовок = ТекстСообщения;
	
	ВремяОкончаниеОтложенногоОбновления = СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления;
	
КонецПроцедуры

&НаСервере
Функция СообщениеОРезультатахОбновления()
	
	Прогресс = ПрогрессВыполненияОбработчиков();
	
	Если Прогресс.ВсегоОбработчиков = Прогресс.ВыполненоОбработчиков Тогда
		
		Если Прогресс.ВсегоОбработчиков = 0 Тогда
			Элементы.ИнформацияОтложенныеОбработчикиОтсутствуют.Видимость = Истина;
			Элементы.ИнформацияОтложенноеОбновлениеЗавершено.Видимость    = Ложь;
			Элементы.ГруппаПереходКСпискуОтложенныхОбработчиков.Видимость = Ложь;
			ТекстСообщения = "";
		Иначе
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Все процедуры обновления выполнены успешно (%1)'"), Прогресс.ВыполненоОбработчиков);
		КонецЕсли;
		Элементы.КартинкаЗавершено.Картинка = БиблиотекаКартинок.Успешно32;
		ОбновлениеЗавершеноУспешно = Истина;
	Иначе
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Не все процедуры удалось выполнить (выполнено %1 из %2)'"), 
			Прогресс.ВыполненоОбработчиков, Прогресс.ВсегоОбработчиков);
		Элементы.КартинкаЗавершено.Картинка = БиблиотекаКартинок.Ошибка32;
	КонецЕсли;
	Возврат ТекстСообщения;
	
КонецФункции

&НаСервере
Процедура ОбновитьИнформациюОХодеОбновления(ОбновлениеЗавершено = Ложь)
	
	Прогресс = ПрогрессВыполненияОбработчиков();
	
	Если Прогресс.ВсегоОбработчиков = Прогресс.ВыполненоОбработчиков Тогда
		ОбновлениеЗавершено = Истина;
	КонецЕсли;
	
	Элементы.ИнформацияСтатусОбновления.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Выполнено: %1 из %2'"),
		Прогресс.ВыполненоОбработчиков,
		Прогресс.ВсегоОбработчиков);
	
	ОбновитьИнформациюПоПроблемам();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьИнформациюПоПроблемам()
	
	// Отображение информации о проблеме с обработчиками.
	КоличествоПроблемВОбработчиках = ПроблемныеСитуацииВОбработчикахОбновления();
	Если КоличествоПроблемВОбработчиках <> 0 И Не ОбновлениеЗавершеноУспешно Тогда
		ТекстИндикатора = НСтр("ru = 'Проблемы с обработчиками'");
	Иначе
		ТекстИндикатора = НСтр("ru = 'Проблем с обработчиками не обнаружено'");
	КонецЕсли;
	
	Элементы.ПроблемныеСитуации.Заголовок = ТекстИндикатора; // На странице прогресса обновления.
	Элементы.ПроблемныеСитуацииЗавершено.Заголовок = ТекстИндикатора; // На странице завершенного обновления.
	
	// Отображение информации о проблеме с данными.
	КоличествоПроблемСДанными = ОбновлениеИнформационнойБазыСлужебный.КоличествоПроблемСДанными();
	Если КоличествоПроблемСДанными <> 0 Тогда
		ТекстИндикатора = НСтр("ru = 'Проблемы с данными (%1)'");
		ТекстИндикатора = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстИндикатора, КоличествоПроблемСДанными);
	Иначе
		ТекстИндикатора = НСтр("ru = 'Проблем с данными не обнаружено'");
	КонецЕсли;
	
	Элементы.ПроблемыСДанными.Заголовок = ТекстИндикатора; // На странице прогресса обновления.
	Элементы.ПроблемыСДаннымиЗавершено.Заголовок = ТекстИндикатора; // На странице завершенного обновления
	
	// Оформление элементов индикации проблем с данными.
	ГиперссылкаПроблемСОбработчиками = Ложь;
	ГиперссылкаПроблемСДанными       = Ложь;
	КартинкаПроблемСОбработчиками = БиблиотекаКартинок.ОформлениеЗнакФлажок;
	КартинкаПроблемСДанными       = БиблиотекаКартинок.ОформлениеЗнакФлажок;
	
	Если КоличествоПроблемВОбработчиках <> 0 И КоличествоПроблемСДанными <> 0 Тогда
		Если Не ОбновлениеЗавершеноУспешно Тогда
			КартинкаПроблемСОбработчиками = Элементы.КартинкаШаблон.Картинка;
			ГиперссылкаПроблемСОбработчиками = Истина;
		КонецЕсли;
		КартинкаПроблемСДанными       = Элементы.КартинкаШаблон.Картинка;
		ГиперссылкаПроблемСДанными       = Истина;
		
	ИначеЕсли КоличествоПроблемВОбработчиках <> 0 И Не ОбновлениеЗавершеноУспешно И КоличествоПроблемСДанными = 0 Тогда
		КартинкаПроблемСОбработчиками = Элементы.КартинкаШаблон.Картинка;
		ГиперссылкаПроблемСОбработчиками = Истина;
		
	ИначеЕсли КоличествоПроблемВОбработчиках = 0 И КоличествоПроблемСДанными <> 0 Тогда
		КартинкаПроблемСДанными    = Элементы.КартинкаШаблон.Картинка;
		ГиперссылкаПроблемСДанными = Истина;
		
	КонецЕсли;
	
	Элементы.ПроблемыСДанными.Гиперссылка   = ГиперссылкаПроблемСДанными;
	Элементы.ПроблемныеСитуации.Гиперссылка = ГиперссылкаПроблемСОбработчиками;
	Элементы.ПроблемыСДаннымиЗавершено.Гиперссылка   = ГиперссылкаПроблемСДанными;
	Элементы.ПроблемныеСитуацииЗавершено.Гиперссылка = ГиперссылкаПроблемСОбработчиками;
	
	Элементы.ДекорацияИндикацияПроблем.Картинка         = КартинкаПроблемСОбработчиками;
	Элементы.ДекорацияИндикацияПроблемСДанными.Картинка = КартинкаПроблемСДанными;
	Элементы.ДекорацияИндикацияПроблемЗавершено.Картинка         = КартинкаПроблемСОбработчиками;
	Элементы.ДекорацияИндикацияПроблемСДаннымиЗавершено.Картинка = КартинкаПроблемСДанными;
	
	// Отображение предупреждения о зацикливании обработки данных.
	ПредупреждатьОЗацикливании = Ложь;
	Если ПриоритетОбновления = "ОбработкаДанных"
		И ЗаданиеАктивно
		И ЗавершенныеВсеПоследовательныеОбработчики() Тогда
		СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
		ДатаНачалаСеансаОбновления = СведенияОбОбновлении.ДатаНачалаСеансаОбновления;
		Если ДатаНачалаСеансаОбновления <> Неопределено
			И ТекущаяДатаСеанса() - ДатаНачалаСеансаОбновления > 5400
			И Не ЕстьИнтервалыПрогрессаОбработкиДанных() Тогда
			ПредупреждатьОЗацикливании = Истина;
		КонецЕсли;
	КонецЕсли;
	
	Элементы.ДекорацияПредупреждениеОЗацикливании.Видимость = ПредупреждатьОЗацикливании;
КонецПроцедуры

&НаСервере
Функция ПрогрессВыполненияОбработчиков()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("РежимВыполнения", Перечисления.РежимыВыполненияОбработчиков.Отложенно);
	Запрос.УстановитьПараметр("Статус", Перечисления.СтатусыОбработчиковОбновления.Выполнен);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(ОбработчикиОбновления.ИмяОбработчика) КАК Количество
		|ИЗ
		|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновления
		|ГДЕ
		|	ОбработчикиОбновления.РежимВыполнения = &РежимВыполнения
		|	И ОбработчикиОбновления.Статус = &Статус";
	Результат = Запрос.Выполнить().Выгрузить();
	ВыполненоОбработчиков = Результат[0].Количество;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(ОбработчикиОбновления.ИмяОбработчика) КАК Количество
		|ИЗ
		|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновления
		|ГДЕ
		|	ОбработчикиОбновления.РежимВыполнения = &РежимВыполнения";
	Результат = Запрос.Выполнить().Выгрузить();
	ВсегоОбработчиков = Результат[0].Количество;
	
	Результат = Новый Структура;
	Результат.Вставить("ВсегоОбработчиков", ВсегоОбработчиков);
	Результат.Вставить("ВыполненоОбработчиков", ВыполненоОбработчиков);
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ЗавершенныеВсеПоследовательныеОбработчики()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("РежимВыполненияОтложенногоОбработчика", Перечисления.РежимыВыполненияОтложенныхОбработчиков.Последовательно);
	Запрос.УстановитьПараметр("Статус", Перечисления.СтатусыОбработчиковОбновления.Выполнен);
	Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ИСТИНА
		|ИЗ
		|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновления
		|ГДЕ
		|	ОбработчикиОбновления.РежимВыполненияОтложенногоОбработчика = &РежимВыполненияОтложенногоОбработчика
		|	И ОбработчикиОбновления.Статус <> &Статус";
	
	Возврат Запрос.Выполнить().Пустой();
	
КонецФункции

&НаСервере
Функция ЕстьИнтервалыПрогрессаОбработкиДанных()
	
	ПроверяемыйИнтервал = НачалоЧаса(ТекущаяДатаСеанса() - 7200);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИнтервалЧас", ПроверяемыйИнтервал);
	Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ИСТИНА
		|ИЗ
		|	РегистрСведений.ПрогрессОбновления КАК ПрогрессОбновления
		|ГДЕ
		|	ПрогрессОбновления.ИнтервалЧас >= &ИнтервалЧас";
	
	Возврат Не Запрос.Выполнить().Пустой();
	
КонецФункции

&НаСервере
Процедура УстановитьРасписаниеОтложенногоОбновления(НовоеРасписание)
	
	ОтборЗаданий = Новый Структура;
	ОтборЗаданий.Вставить("Метаданные", Метаданные.РегламентныеЗадания.ОтложенноеОбновлениеИБ);
	Задания = РегламентныеЗаданияСервер.НайтиЗадания(ОтборЗаданий);
	
	Для Каждого Задание Из Задания Цикл
		ПараметрыЗадания = Новый Структура("Расписание", НовоеРасписание);
		РегламентныеЗаданияСервер.ИзменитьЗадание(Задание, ПараметрыЗадания);
	КонецЦикла;
	
	Расписание = НовоеРасписание;
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьРасписаниеПослеУстановкиРасписания(НовоеРасписание, ДополнительныеПараметры) Экспорт
	
	Если НовоеРасписание <> Неопределено Тогда
		Если НовоеРасписание.ПериодПовтораВТечениеДня = 0 Тогда
			Оповещение = Новый ОписаниеОповещения("ИзменитьРасписаниеПослеВопроса", ЭтотОбъект, НовоеРасписание);
			
			КнопкиВопроса = Новый СписокЗначений;
			КнопкиВопроса.Добавить("НастроитьРасписание", НСтр("ru = 'Настроить расписание'"));
			КнопкиВопроса.Добавить("РекомендуемыеНастройки", НСтр("ru = 'Установить рекомендуемые настройки'"));
			
			ТекстСообщения = НСтр("ru = 'Дополнительные процедуры обработки данных выполняются небольшими порциями,
				|поэтому для их корректной работы необходимо обязательно задать интервал повтора после завершения.
				|
				|Для этого в окне настройки расписания необходимо перейти на вкладку ""Дневное""
				|и заполнить поле ""Повторять через"".'");
			ПоказатьВопрос(Оповещение, ТекстСообщения, КнопкиВопроса,, "НастроитьРасписание");
		Иначе
			УстановитьРасписаниеОтложенногоОбновления(НовоеРасписание);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьРасписаниеПослеВопроса(Результат, НовоеРасписание) Экспорт
	
	Если Результат = "РекомендуемыеНастройки" Тогда
		НовоеРасписание.ПериодПовтораВТечениеДня = 60;
		НовоеРасписание.ПаузаПовтора = 60;
		УстановитьРасписаниеОтложенногоОбновления(НовоеРасписание);
	Иначе
		ОписаниеОповещения = Новый ОписаниеОповещения("ИзменитьРасписаниеПослеУстановкиРасписания", ЭтотОбъект);
		Диалог = Новый ДиалогРасписанияРегламентногоЗадания(НовоеРасписание);
		Диалог.Показать(ОписаниеОповещения);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьРезультатОбновленияНаСервере()
	
	Элементы.ГруппаУстановленныеИсправления.Видимость = Ложь;
	// Если это первый запуск после обновления конфигурации, то запоминаем и сбрасываем статус.
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеКонфигурации") Тогда
		ИнформацияПоИсправлениям = Неопределено;
		МодульОбновлениеКонфигурации = ОбщегоНазначения.ОбщийМодуль("ОбновлениеКонфигурации");
		МодульОбновлениеКонфигурации.ПроверитьСтатусОбновления(РезультатОбновления, КаталогСкрипта, ИнформацияПоИсправлениям);
		ОбработатьРезультатУстановкиИсправлений(ИнформацияПоИсправлениям);
	КонецЕсли;
	
	Если ПустаяСтрока(КаталогСкрипта) Тогда 
		Элементы.ИнформацияДляТехническойПоддержки.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьРезультатУстановкиИсправлений(ИнформацияПоИсправлениям)
	
	Если ТипЗнч(ИнформацияПоИсправлениям) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	ВсегоПатчей = ИнформацияПоИсправлениям.ВсегоПатчей;
	Если ВсегоПатчей = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Элементы.ГруппаУстановленныеИсправления.Видимость = Истина;
	Исправления.ЗагрузитьЗначения(ИнформацияПоИсправлениям.Установленные);
	
	Если ИнформацияПоИсправлениям.НеУстановлено > 0 Тогда
		УспешноУстановлено = ВсегоПатчей - ИнформацияПоИсправлениям.НеУстановлено;
		Ссылка = Новый ФорматированнаяСтрока(НСтр("ru = 'Не удалось установить исправления'"),,,, "НеудачнаяУстановка");
		НадписьИсправления = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '(%1 из %2)'"), УспешноУстановлено, ВсегоПатчей);
		НадписьИсправления = Новый ФорматированнаяСтрока(Ссылка, " ", НадписьИсправления);
		Элементы.ГруппаУстановленныеИсправления.ТекущаяСтраница = Элементы.ГруппаОшибкаУстановкиИсправлений;
		Элементы.ИнформацияОшибкаИсправлений.Заголовок = НадписьИсправления;
	Иначе
		Ссылка = Новый ФорматированнаяСтрока(НСтр("ru = 'Исправления (патчи)'"),,,, "УстановленныеИсправления");
		НадписьИсправления = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'успешно установлены (%1)'"), ВсегоПатчей);
		НадписьИсправления = Новый ФорматированнаяСтрока(Ссылка, " ", НадписьИсправления);
		Элементы.ИнформацияИсправленияУстановлены.Заголовок = НадписьИсправления;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьРезультатОбновленияНаКлиенте()
	
	Если РезультатОбновления <> Неопределено
		И ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеКонфигурации") Тогда
		
		МодульОбновлениеКонфигурацииКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбновлениеКонфигурацииКлиент");
		МодульОбновлениеКонфигурацииКлиент.ОбработатьРезультатОбновления(РезультатОбновления, КаталогСкрипта);
		Если РезультатОбновления = Ложь Тогда
			Элементы.ГруппаРезультатыОбновления.ТекущаяСтраница = Элементы.ГруппаОшибкаОбновления;
			// Если обновление конфигурации не выполнилось, то отложенные обработчики так же не выполняются.
			Элементы.СтатусОбновления.Видимость = Ложь;
			Элементы.ПодсказкаГдеНайтиЭтуФорму.Видимость = Ложь;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьУстановленныеИсправления()
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеКонфигурации") Тогда
		МодульОбновлениеКонфигурацииКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбновлениеКонфигурацииКлиент");
		МодульОбновлениеКонфигурацииКлиент.ПоказатьУстановленныеИсправления(Исправления);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьКоличествоПотоковОбновленияИнформационнойБазы()
	
	Если ПравоДоступа("Чтение", Метаданные.Константы.КоличествоПотоковОбновленияИнформационнойБазы) Тогда
		КоличествоПотоковОбновленияИнформационнойБазы =
			ОбновлениеИнформационнойБазыСлужебный.КоличествоПотоковОбновленияИнформационнойБазы();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьКоличестваПотоковОбновленияИнформационнойБазы(Форма)
	
	Доступно = (Форма.ПриоритетОбновления = "ОбработкаДанных");
	Форма.Элементы.КоличествоПотоковОбновленияИнформационнойБазы.Доступность = Доступно;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьВидимостьКоличестваПотоковОбновленияИнформационнойБазы()
	
	РазрешеноМногопоточноеОбновление = ОбновлениеИнформационнойБазыСлужебный.РазрешеноМногопоточноеОбновление();
	Элементы.КоличествоПотоковОбновленияИнформационнойБазы.Видимость = РазрешеноМногопоточноеОбновление;
	
	Если РазрешеноМногопоточноеОбновление Тогда
		Элементы.ПриоритетОбновления.ОтображениеПодсказки = ОтображениеПодсказки.Нет;
	Иначе
		Элементы.ПриоритетОбновления.ОтображениеПодсказки = ОтображениеПодсказки.Кнопка;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПроблемныеСитуацииВОбработчикахОбновления()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("РежимВыполнения", Перечисления.РежимыВыполненияОбработчиков.Отложенно);
	Запрос.УстановитьПараметр("Статус", Перечисления.СтатусыОбработчиковОбновления.Выполнен);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ОбработчикиОбновления.ИмяОбработчика КАК ИмяОбработчика,
		|	ОбработчикиОбновления.СтатистикаВыполнения КАК СтатистикаВыполнения
		|ИЗ
		|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновления
		|ГДЕ
		|	ОбработчикиОбновления.РежимВыполнения = &РежимВыполнения";
	Результат = Запрос.Выполнить().Выгрузить();
	
	КоличествоПроблем = 0;
	Для Каждого Строка Из Результат Цикл
		СтатистикаВыполнения = Строка.СтатистикаВыполнения;
		СтатистикаВыполнения = СтатистикаВыполнения.Получить();
		Если ТипЗнч(СтатистикаВыполнения) <> Тип("Соответствие") Тогда
			Продолжить;
		КонецЕсли;
		
		Если СтатистикаВыполнения["ЕстьОшибки"] = Истина Тогда
			КоличествоПроблем = КоличествоПроблем + 1;
		КонецЕсли;
	КонецЦикла;
	
	Возврат КоличествоПроблем;
	
КонецФункции

&НаСервере
Процедура ПроверитьВыполнениеОтложенногоОбновления(СведенияОбОбновлении)
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Возврат;
	КонецЕсли;
	
	Задание = РегламентныеЗаданияСервер.Задание(Метаданные.РегламентныеЗадания.ОтложенноеОбновлениеИБ);
	ЗаданиеВыполняется = Ложь;
	Сообщения = Новый Массив;
	ИдентификаторГиперссылки = "";
	Если Задание.Использование Тогда
		ОтборЗаданий = Новый Структура;
		ОтборЗаданий.Вставить("ИмяМетода", "ОбновлениеИнформационнойБазыСлужебный.ВыполнитьОтложенноеОбновление");
		НайденныеЗадания = ФоновыеЗадания.ПолучитьФоновыеЗадания(ОтборЗаданий);
		
		Для Каждого ФоновоеЗадание Из НайденныеЗадания Цикл
			// Есть активное фоновое задание обновления.
			Если ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
				ЗаданиеАктивно = Истина;
				ЗаданиеВыполняется = Истина;
				Прервать;
			КонецЕсли;
			ЗаданиеАктивно = Ложь;
			
			// АПК:143-выкл в фоновых заданиях используется текущая дата.
			// Фоновое задание недавно выполнялось.
			Если ФоновоеЗадание.Конец > ТекущаяДата() - Задание.Расписание.ПериодПовтораВТечениеДня * 5 Тогда
				ЗаданиеВыполняется = Истина;
			КонецЕсли;
			
			Если Не ЗаданиеВыполняется Тогда
				ТребуетсяВыполнение = Задание.Расписание.ТребуетсяВыполнение(ТекущаяДата(), ФоновоеЗадание.Начало, ФоновоеЗадание.Конец);
				ЗаданиеВыполняется = Не ТребуетсяВыполнение;
			КонецЕсли;
			// АПК:143-вкл
			
			Прервать;
		КонецЦикла;
		
		ТекстСообщения = НСтр("ru = 'Регламентное задание <b>Отложенное обновление</b> включено, но
			|не выполняется. Вероятно включена блокировка выполнения регламентных заданий.'");
		Сообщения.Добавить(СтрСоединить(СтрРазделить(ТекстСообщения, Символы.ПС), " "));
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей") Тогда
			Сообщения.Добавить(НСтр("ru = '<a href=""%1"">Проверить блокировку регламентных заданий</a>'"));
			ИдентификаторГиперссылки = "ПроверитьБлокировку";
		КонецЕсли;
	Иначе
		ТекстСообщения = НСтр("ru = 'Дополнительные процедуры обработки данных не выполняются,
			|т.к. отключено регламентное задание <b>Отложенное обновление</b>.'");
		Сообщения.Добавить(СтрСоединить(СтрРазделить(ТекстСообщения, Символы.ПС), " "));
		Сообщения.Добавить(НСтр("ru = '<a href=""%1"">Включить</a>'"));
		ИдентификаторГиперссылки = "Включить";
	КонецЕсли;
	ТекстСообщения = СтроковыеФункции.ФорматированнаяСтрока(СтрСоединить(Сообщения, Символы.ПС), ИдентификаторГиперссылки);
	Элементы.ПояснениеОбновлениеНеВыполняется.Заголовок = ТекстСообщения;
	
	Элементы.ГруппаШапкаКлиентСервер.Видимость = ЗаданиеВыполняется;
	Элементы.ГруппаШапкаОбновлениеНеВыполняется.Видимость = Не ЗаданиеВыполняется;
	
КонецПроцедуры

&НаСервере
Процедура ВключитьРегламентноеЗадание()
	ОбновлениеИнформационнойБазыСлужебный.ПриВключенииОтложенногоОбновления(Истина);
КонецПроцедуры

&НаСервере
Функция ЕстьОбработчикиСПараллельнымРежимомВыполнения()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("РежимВыполненияОтложенногоОбработчика", Перечисления.РежимыВыполненияОтложенныхОбработчиков.Параллельно);
	Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ИСТИНА
		|ИЗ
		|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновления
		|ГДЕ
		|	ОбработчикиОбновления.РежимВыполненияОтложенногоОбработчика = &РежимВыполненияОтложенногоОбработчика";
	Возврат Не Запрос.Выполнить().Пустой();
	
КонецФункции

#КонецОбласти
