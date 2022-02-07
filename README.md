# Плеер Volt Razor Play'N'Stop v0.1 (WAV Плеер, 2016 год разработки)

**Краткое описание**

Первый большой проект (на 2016 год) с использованием микроконтроллера после устройств (усилители, АЦП и т.д.) 
с использованием исключительно дискретных комопнентов (ОУ, транисторы, дискретная логика и т.д.).

Плеер музыки в формате WAV на базе микроконтроллера Atmel AtMega328p **(не Ардуино!)**.
Проект разработан в среде Code Vision AVR. Проект выложен вместе со средой. 
Запустить CodeVisionAVR необходимо из папки BIN/cvavr.exe. Файл проекта находится в дериктории
верхнего уровня и называется _nokia_lcd_test.prj_.

Для чтения файлов с SD карты используется библиотека файловой системы для микроконтроллеров AVR : Petit FatFS. 

**Принципиальная схема** плеера находится в папке Schematics. Плата для WAV плеера никогда не разрабатывалась.
Устройство представлено только в виде макета на нескольких макетных платах.
Планировалось сделать данное устройство на диплом бакалавра, но ввиду его большой сложности по части документации
совместно с нехваткой времени и отсутствия разработанной конечной платы, плеер был заброшен и оставлен в виде макета.

Были планы его дорабатывать дальше, но, так как микроконтроллеры AVR уже проигрывали по цене и возможностям 
микроконтроллерам STM32, а распространенность платформы Arduino стала шире, то дальнейшая разработка уже не имела смысла.

Используемые интерфейсы AtMega328p: I2C (TWI), SPI, выводы под клавиатуру.
Используемые модули:
1) Модуль SD карты (SPI);
2) Модуль часов реального времени с батарейкой (I2C);
3) SRAM память на шине SPI в качестве видеопамяти для хранения текущего изображения;
4) Самодельный модуль с дисплеем от телефона Nokia 6610
5) ...

**Весь проект занимает 96 % Flash памяти AtMega328p**, почти под завязку.


**Видео примера работы устройства**

