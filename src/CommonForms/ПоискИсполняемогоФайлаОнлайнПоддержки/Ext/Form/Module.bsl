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
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ИдентификаторКлиента = СистемнаяИнформация.ИдентификаторКлиента;
	ПутьКФайлу = ВызовОнлайнПоддержкиВызовСервера.РасположениеИсполняемогоФайла(ИдентификаторКлиента);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если НЕ ОбщегоНазначенияКлиент.ЭтоWindowsКлиент() Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Для работы с приложением необходима операционная система Microsoft Windows.'"));
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПутьКФайлуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	Оповещение = Новый ОписаниеОповещения("ПутьКФайлуНачалоВыбораЗавершение", ЭтотОбъект);
	ВызовОнлайнПоддержкиКлиент.ВыбратьФайлВызовОнлайнПоддержки(Оповещение, ПутьКФайлу);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Сохранить(Команда)
	
	ИдентификаторКлиента = ВызовОнлайнПоддержкиКлиент.ИдентификаторКлиента();
	// Записывает путь к исполняемому файлу в регистр сведений.
	НовыйПутьКИсполняемомуФайлу(ИдентификаторКлиента, ПутьКФайлу); 
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПутьКФайлуНачалоВыбораЗавершение(НовыйПутьКФайлу, ДополнительныеПараметры) Экспорт
	Если НовыйПутьКФайлу <> "" Тогда
		ПутьКФайлу = НовыйПутьКФайлу;
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Процедура НовыйПутьКИсполняемомуФайлу(ИдентификаторКлиента, ПутьКФайлу)
	ВызовОнлайнПоддержки.СохранитьРасположениеИсполняемогоФайлаВызовОнлайнПоддержки(ИдентификаторКлиента, ПутьКФайлу);
КонецПроцедуры 

#КонецОбласти





