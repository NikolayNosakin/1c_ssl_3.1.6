﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Определяет внутренний идентификатор классификатора для подсистемы РаботаСКлассификаторами.
//
// Возвращаемое значение:
//  Строка - идентификатор классификатора.
//
Функция ИдентификаторКлассификатора() Экспорт
	
	Возврат "AccreditedCA";

КонецФункции

// См. РаботаСКлассификаторамиПереопределяемый.ПриЗагрузкеКлассификатора.
Процедура ЗагрузитьДанныеАккредитованныхУЦ(Версия, Адрес, Обработан, ДополнительныеПараметры) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Возврат;
	КонецЕсли;
	
	ИмяАрхива = ПолучитьИмяВременногоФайла("zip");
	ДвоичныеДанныеАрхива = ПолучитьИзВременногоХранилища(Адрес); // ДвоичныеДанные
	ДвоичныеДанныеАрхива.Записать(ИмяАрхива);
		
	КаталогОбновлений = ФайловаяСистема.СоздатьВременныйКаталог(
		Строка(Новый УникальныйИдентификатор));
	
	ЧтениеZipФайла = Новый ЧтениеZipФайла(ИмяАрхива);
	ИмяФайлаПериодыДействия = Неопределено;
	ИмяФайлаДатыОкончания = Неопределено;
	
	Для Каждого ЭлементАрхива Из ЧтениеZipФайла.Элементы Цикл
		Если СтрНачинаетсяС(ЭлементАрхива.Имя, "AccreditedCA") Тогда
			ИмяФайлаПериодыДействия = ЭлементАрхива.Имя;
			ЧтениеZipФайла.Извлечь(ЭлементАрхива, КаталогОбновлений);
			Продолжить;
		КонецЕсли;
		Если СтрНачинаетсяС(ЭлементАрхива.Имя, "CAExpirationDateList") Тогда
			ИмяФайлаДатыОкончания = ЭлементАрхива.Имя;
			ЧтениеZipФайла.Извлечь(ЭлементАрхива, КаталогОбновлений);
			Продолжить;
		КонецЕсли;
	КонецЦикла;
	
	ЧтениеZipФайла.Закрыть();
	
	ДанныеУЦ = Константы.АккредитованныеУдостоверяющиеЦентры.Получить().Получить();
	
	Если ДанныеУЦ = Неопределено Тогда
		ДанныеУЦ = Новый Структура;
		ДанныеУЦ.Вставить("ПериодыДействия", Новый Структура("Данные, Версия, ДатаОбновления", Новый Соответствие, 0, Дата(1,1,1)));
		ДанныеУЦ.Вставить("ДатыОкончанияДействия", Новый Структура("Данные, Версия, ДатаОбновления", Новый Соответствие, 0, Дата(1,1,1)));
		ДанныеУЦ.Вставить("ГосударственныеУЦ", Новый Соответствие);
	КонецЕсли;
	
	Если ИмяФайлаДатыОкончания <> Неопределено Тогда
		
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.ОткрытьФайл(КаталогОбновлений + ИмяФайлаДатыОкончания);
		ДатыОкончания = ПрочитатьJSON(ЧтениеJSON); // Структура
		ЧтениеJSON.Закрыть();
		
		// Подготовка соответствия для быстрого поиска.
		Соответствие = Новый Соответствие;
		Для Каждого УЦ Из ДатыОкончания Цикл
			Соответствие.Вставить(УЦ.ОГРН, ПрочитатьДатуJSON(УЦ.ДатаОкончанияДействия, ФорматДатыJSON.ISO));
		КонецЦикла;
	
		ДанныеУЦ.ДатыОкончанияДействия.Данные = Соответствие;
		ДанныеУЦ.ДатыОкончанияДействия.Версия = Версия;
		ДанныеУЦ.ДатыОкончанияДействия.ДатаОбновления = ТекущаяДатаСеанса();
	Иначе
		ДанныеУЦ.ДатыОкончанияДействия.Данные = Новый Соответствие;
		ДанныеУЦ.ДатыОкончанияДействия.Версия = Версия;
		ДанныеУЦ.ДатыОкончанияДействия.ДатаОбновления = ТекущаяДатаСеанса();
	КонецЕсли;
	
	Если ИмяФайлаПериодыДействия <> Неопределено Тогда
		
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.ОткрытьФайл(КаталогОбновлений + ИмяФайлаПериодыДействия);
		СписокУЦ = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		
		// Подготовка соответствия для быстрого поиска.
		Соответствие = Новый Соответствие;
		ГосударственныеУЦ = Новый Соответствие;
		Для Каждого УЦ Из СписокУЦ Цикл
			
			Наименование = УЦ.Наименование; // Строка
			Наименование = ЭлектроннаяПодписьКлиентСерверЛокализация.ПодготовитьПолеПоиска(Наименование);
			КраткоеНаименование = ЭлектроннаяПодписьКлиентСерверЛокализация.ПодготовитьПолеПоиска(УЦ.КраткоеНаименование);
			
			ПериодыДействияМассив = Новый Массив;
			Для Каждого ТекущийПериод Из УЦ.ПериодыДействия Цикл
				ПериодДействияСтруктура = Новый Структура("ДатаС, ДатаПо");
				ПериодДействияСтруктура.ДатаС = ПрочитатьДатуJSON(ТекущийПериод.ДатаС, ФорматДатыJSON.ISO);
				Если ЗначениеЗаполнено(ТекущийПериод.ДатаПо) Тогда
					ПериодДействияСтруктура.ДатаПо = ПрочитатьДатуJSON(ТекущийПериод.ДатаПо, ФорматДатыJSON.ISO);
				КонецЕсли;
				ПериодыДействияМассив.Добавить(ПериодДействияСтруктура);
			КонецЦикла;
			
			Соответствие.Вставить(УЦ.ОГРН, ПериодыДействияМассив);
			Соответствие.Вставить(Наименование, ПериодыДействияМассив);
			Соответствие.Вставить(КраткоеНаименование, ПериодыДействияМассив);
			Если УЦ.Государственный Тогда
				ГосударственныеУЦ.Вставить(УЦ.ОГРН, Истина);
				ГосударственныеУЦ.Вставить(Наименование, Истина);
				ГосударственныеУЦ.Вставить(КраткоеНаименование, Истина);
			КонецЕсли;
		КонецЦикла;
		
		ДанныеУЦ.ПериодыДействия.Данные = Соответствие;
		ДанныеУЦ.ГосударственныеУЦ = ГосударственныеУЦ;
		ДанныеУЦ.ПериодыДействия.Версия = Версия;
		ДанныеУЦ.ПериодыДействия.ДатаОбновления = ТекущаяДатаСеанса();
		
	КонецЕсли;
		
	ХранилищеЗначения = Новый ХранилищеЗначения(ДанныеУЦ, Новый СжатиеДанных(6));
	Константы.АккредитованныеУдостоверяющиеЦентры.Установить(ХранилищеЗначения);
	
	ФайловаяСистема.УдалитьВременныйКаталог(КаталогОбновлений);
	ФайловаяСистема.УдалитьВременныйФайл(ИмяАрхива);
	
	Обработан = Истина;
		
КонецПроцедуры 

Функция ОбновитьКлассификатор() Экспорт
	
	ДатаПоследнегоОбновления = Константы.ДатаПоследнегоОбновленияКлассификатораОшибок.Получить();
	ДатаПоследнегоИзменения = Неопределено;
	
	АдресКлассификатора = АдресКлассификатораОшибок();
	ПолныйАдрес = АдресКлассификатора.Протокол + АдресКлассификатора.АдресСервера + "/" + АдресКлассификатора.АдресРесурса;
	ДанныеКлассификатора = Неопределено;
	ТекстОшибки = "";
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
		
		МодульПолучениеФайловИзИнтернетаКлиентСервер = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернетаКлиентСервер");
		ПараметрыПолученияФайла = МодульПолучениеФайловИзИнтернетаКлиентСервер.ПараметрыПолученияФайла();
		ПараметрыПолученияФайла.Заголовки.Вставить("If-Modified-Since", 
			ОбщегоНазначенияКлиентСервер.ДатаHTTP(ДатаПоследнегоОбновления));
		
		МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
		РезультатЗагрузки = МодульПолучениеФайловИзИнтернета.СкачатьФайлВоВременноеХранилище(
			ПолныйАдрес, ПараметрыПолученияФайла, Ложь);
			
		Если РезультатЗагрузки.КодСостояния = 304 Тогда // Классификатор не был обновлен.
			Возврат "";
		ИначеЕсли РезультатЗагрузки.Статус Тогда
			ДатаПоследнегоИзменения = ДатаПоследнегоИзмененияФайла(РезультатЗагрузки);
			ДанныеКлассификатора = ПолучитьИзВременногоХранилища(РезультатЗагрузки.Путь);
			УдалитьИзВременногоХранилища(РезультатЗагрузки.Путь);
		Иначе
			Возврат РезультатЗагрузки.СообщениеОбОшибке;
		КонецЕсли;
		
	Иначе
		
		Соединение = Новый HTTPСоединение(АдресКлассификатора.АдресСервера,,,,, 20);
		
		Заголовки = Новый Соответствие;
		Заголовки.Вставить("Accept-Charset", "UTF-8");
		Заголовки.Вставить("If-Modified-Since", ОбщегоНазначенияКлиентСервер.ДатаHTTP(ДатаПоследнегоОбновления));
		
		Ответ = Соединение.Получить(
			Новый HTTPЗапрос(АдресКлассификатора.АдресРесурса, Заголовки));
			
		Если Ответ.КодСостояния = 304 Тогда // Классификатор не был обновлен.
			Возврат "";
		ИначеЕсли Ответ.КодСостояния = 200 Тогда
			ДатаПоследнегоИзменения = ДатаПоследнегоИзмененияФайла(Ответ);
			ДанныеКлассификатора = Ответ.ПолучитьТелоКакСтроку();
		Иначе ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'HTTP ответ - %1'"), Строка(Ответ.КодСостояния));
		КонецЕсли;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ТекстОшибки)
	   И Не ЗначениеЗаполнено(ДанныеКлассификатора) Тогда
		
		ТекстОшибки = НСтр("ru = 'Получены пустые данные.'");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстОшибки) Тогда
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'При скачивании данных по адресу:
			           |%1
			           |возникла ошибка:
			           |%2'"),
			ПолныйАдрес,
			ТекстОшибки);
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебный.ЗаписатьДанныеКлассификатора(ДанныеКлассификатора, ДатаПоследнегоИзменения);
	
	Возврат "";
	
КонецФункции

Функция АккредитованныеУдостоверяющиеЦентры() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ДанныеУдостоверяющихЦентров = Константы.АккредитованныеУдостоверяющиеЦентры.Получить().Получить();
	
	Если ДанныеУдостоверяющихЦентров = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Результат = Новый Структура;
	Результат.Вставить("ПериодыДействия", ДанныеУдостоверяющихЦентров.ПериодыДействия.Данные);
	Результат.Вставить("ДатаПроверкиОбновления", ДанныеУдостоверяющихЦентров.ПериодыДействия.ДатаОбновления);
	Результат.Вставить("ДатыОкончанияДействия", ДанныеУдостоверяющихЦентров.ДатыОкончанияДействия.Данные);
	Результат.Вставить("ГосударственныеУЦ", ДанныеУдостоверяющихЦентров.ГосударственныеУЦ);
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДатаПоследнегоИзмененияФайла(РезультатЗагрузки)
	
	Заголовки = Неопределено;
	Если ТипЗнч(РезультатЗагрузки) = Тип("Структура") Тогда
		Заголовки = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(РезультатЗагрузки, "Заголовки", Неопределено);
	ИначеЕсли ТипЗнч(РезультатЗагрузки) = Тип("HTTPОтвет") Тогда
		Заголовки = РезультатЗагрузки.Заголовки;
	КонецЕсли;
	
	Если Заголовки = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ДатаПоследнегоИзмененияСтрока = Заголовки["Last-Modified"];
	Если ДатаПоследнегоИзмененияСтрока <> Неопределено Тогда
		Возврат ОбщегоНазначенияКлиентСервер.ДатаRFC1123(ДатаПоследнегоИзмененияСтрока);
	КонецЕсли;
	
	Возврат Неопределено;

КонецФункции

Функция АдресКлассификатораОшибок()
	
	АдресКлассификатора = Новый Структура;
	АдресКлассификатора.Вставить("Протокол", "http://");
	АдресКлассификатора.Вставить("АдресСервера", "downloads.v8.1c.ru");
	АдресКлассификатора.Вставить("АдресРесурса", "content/LED/settings/ErrorClassifier/classifier2.json");

	Возврат АдресКлассификатора;
	
КонецФункции

#КонецОбласти
