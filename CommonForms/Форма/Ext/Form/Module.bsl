﻿
Процедура СловаНайти(Слово)
	Если Не ПустаяСтрока(Фёст) И Найти(Слово, Фёст) = 0 Тогда
		Сообщить("Первая буква отсутвует в наборе букв");
		Возврат;
	КонецЕсли;
	
	Слово = Гастроном.СловоНормализовать(Слово);
	ТекСлово	= Неопределено;
	Если Справочники.Слова.НайтиПоКоду(Слово).Пустая() Тогда
		ТекСлово = Справочники.Слова.СоздатьЭлемент();
		ТекСлово.ОбменДанными.Загрузка = Истина;
		ТекСлово.Код = Слово;
		ТекСлово.Записать();
	КонецЕсли;
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	СловаБуквы.Буква,
	                      |	СловаБуквы.Количество
	                      |ПОМЕСТИТЬ Буквы
	                      |ИЗ
	                      |	Справочник.Слова.Буквы КАК СловаБуквы
	                      |ГДЕ
	                      |	СловаБуквы.Ссылка.Код = &Код
	                      |;
	                      |
	                      |////////////////////////////////////////////////////////////////////////////////
	                      |ВЫБРАТЬ
	                      |	Слова.Ссылка.Код КАК Код
	                      |ИЗ
	                      |	Справочник.Слова.Буквы КАК Слова
	                      |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Буквы КАК Буквы
	                      |		ПО Слова.Буква = Буквы.Буква
	                      |			И Слова.Количество <= Буквы.Количество
	                      |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Слова.Буквы КАК Контроль
	                      |		ПО Слова.Ссылка = Контроль.Ссылка
	                      |ГДЕ
	                      |	Слова.Ссылка.ПометкаУдаления = ЛОЖЬ
	                      |	И ПОДСТРОКА(Слова.Ссылка.Код, 1, 1) = &Фёст
	                      |
	                      |СГРУППИРОВАТЬ ПО
	                      |	Слова.Ссылка.Код
	                      |
	                      |ИМЕЮЩИЕ
	                      |	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Слова.Буква) = КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Контроль.Буква)
	                      |
	                      |УПОРЯДОЧИТЬ ПО
	                      |	Код");
	Запрос.УстановитьПараметр("Код",	Слово);
	Запрос.УстановитьПараметр("Фёст",	Фёст);
	Если ПустаяСтрока(Фёст) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "И ПОДСТРОКА(Слова.Ссылка.Код, 1, 1) = &Фёст", "")
	КонецЕсли;
	Старт = ТекущаяДата();
	Список = Запрос.Выполнить().Выгрузить();
	Если ПоказыватьЗатраченноеВремя Тогда
		Сообщить("Затраченное время (сек) " + Строка(ТекущаяДата() - Старт));
	КонецЕсли;
	Виктим = Список.Найти(Слово,	"Код");
	Если Виктим <> Неопределено Тогда
		Список.Удалить(Виктим);
	КонецЕсли;
	Если Длина = 0 Тогда
		Слова.Загрузить(Список);
	Иначе
		Слова.Очистить();
		Для Каждого тСтрока Из Список Цикл
			Если СтрДлина(СокрП(тСтрока.Код)) <> Длина Тогда
				Продолжить;
			КонецЕсли;
			нСтрока = Слова.Добавить();
			нСтрока.Код = тСтрока.Код;
		КонецЦикла;
	КонецЕсли;
	
	Если ТипЗнч(ТекСлово) = Тип("СправочникОбъект.Слова") Тогда
		ТекСлово.Удалить();
	КонецЕсли;
КонецПроцедуры

Функция СловВБазе()
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Слова.Ссылка) КАК Количество
	                      |ИЗ
	                      |	Справочник.Слова КАК Слова
	                      |ГДЕ
	                      |	Слова.ПометкаУдаления = ЛОЖЬ");
	Выборка = Запрос.Выполнить().Выбрать();
	Возврат ?(Выборка.Следующий(), Выборка.Количество, 0);
КонецФункции

Процедура СловоУдалить(Код)
	Справочники.Слова.НайтиПоКоду(Код).ПолучитьОбъект().Удалить();
КонецПроцедуры

&НаКлиенте
Процедура НайтиСлова(Команда=Неопределено)
	Если НЕ ПустаяСтрока(Слово) Тогда
		СловаНайти(Слово);
		Сообщить(ВРег(Слово) +". Найдено слов " + Строка(Слова.Количество()));
		
		Если Элементы.Слово.СписокВыбора.НайтиПоЗначению(Слово) = Неопределено Тогда
			Элементы.Слово.СписокВыбора.Добавить(Слово);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СловоПриИзменении(Элемент)
	Модифицированность = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Элементы.Слово.СписокВыбора.Добавить("гастроном");
	Если ПустаяСтрока(Слово) Тогда
		СловВБазе = СловВБазе();
		Сообщить(?(СловВБазе = 0, "Welcome!", "Слов в базе " + Строка(СловВБазе)));
	КонецЕсли;
	//НайтиСлова();
КонецПроцедуры

&НаКлиенте
Процедура СловаПередУдалением(Элемент, Отказ)
	СловоУдалить(Элемент.ТекущиеДанные.Код);
КонецПроцедуры

&НаКлиенте
Процедура ФестНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	Слово = СокрЛП(Слово);
	Элемент.СписокВыбора.Очистить();
	Для Шаг = 1 По СтрДлина(Слово) Цикл
		Если Элемент.СписокВыбора.НайтиПоЗначению(Сред(Слово, Шаг, 1)) = Неопределено Тогда
			Элемент.СписокВыбора.Добавить(Сред(Слово, Шаг, 1));
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры
