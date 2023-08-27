# dice
**dice** es una pequeña utiliza para *shell script de Linux* que permite codificar/decodificar un archivo, o la entrada estándar, a la salida estándar. Para ello utiliza el algoritmo de cifrado DICE.

## El algoritmo DICE
Se trata de un algoritmo de sustitución polialfabético con clave simétrica. Surgió como un pasatiempo, mientras estudiaba métodos criptográficos clásicos. Está pensado para su aplicación mediante papel y boli, por lo que me temo que su seguridad no es muy alta. 

El algoritmo soporta 36 caracteres: [A-Z] y [0-9], que se ordenan en una matriz de 6x6:

|       | **1** | **2** | **3** | **4** | **5** | **6** |
|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
| **1** |   A   |   B   |   C   |   D   |   E   |   F   |
| **2** |   G   |   H   |   I   |   J   |   K   |   L   |
| **3** |   M   |   N   |   O   |   P   |   Q   |   R   |
| **4** |   S   |   T   |   U   |   V   |   W   |   X   |
| **5** |   Y   |   Z   |   0   |   1   |   2   |   3   |
| **6** |   4   |   5   |   6   |   7   |   8   |   9   |

Los caracteres no representados en esta matriz, como espacios o signos de puntuación, no se codifican.

El nombre del algoritmo, **DICE**, viene precisamente del *dado* que se utiliza en la versión de papel y boli para generar aleatoriedad.

### Algoritmo para codificar

1. Se sustituye cada letra del mensaje original por un número de dos dígitos, donde el primero representa la fila en la que aparece el carácter y el segundo la columna:

| h  | o  | l  | a  |    | m  | u  | n  | d  | o  |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 22 | 33 | 26 | 11 |    | 31 | 43 | 32 | 14 | 33 |

2. Los dígitos que representan las filas (primer dígito del número), se sustituyen por una letra aleatoria perteneciente a la fila indicada: Es decir, si la fila es 3, se puede sustituir por S, T, U, V, W o X. Esta letra podrá variar en cada aparición del número 3 como fila.

3. Los dígitos que representan las columnas (segundo dígito del número), se sustituyen por una letra aleatoria perteneciente a la columna indicada: Es decir, si la columna es 4, se puede sustituir por E, K, Q, W, 2 u 8. Esta letra podrá variar en cada aparición del número 4 como columna.

| h  | o  | l  | a  |    | m  | u  | n  | d  | o  |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 22 | 33 | 26 | 11 |    | 31 | 43 | 32 | 14 | 33 |
| IT | M6 | DX | AY |    | O4 | WC | NH | EJ | PI |

De forma que *hola mundo* se podría codificar como *ITM6DXAY O4WCNHEJPI*. Pero *GNNUJL4B MAXCQBF7R0* también sería una combinación válida, por ejemplo. 

### Algoritmo para decodificar

1. Tomamos las letras del mensaje de dos en dos. Sabemos que la primera de ellas representa la fila y la segunda la columna.

| IT | M6 | DX | AY |    | O4 | WC | NH | EJ | PI |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|

2. Sustituimos la letra que representa la fila por el número de fila en el que aparece. De la misma forma, sustituimos la letra que representa la columna por el número de columna al que pertenece la letra en cuestión.

| IT | M6 | DX | AY |    | O4 | WC | NH | EJ | PI |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 22 | 33 | 26 | 11 |    | 31 | 43 | 32 | 14 | 33 |

3. Sustituimos cada par de dígitos por el carácter que aparece en la matriz en la posición indicada por la fila/columna.

| IT | M6 | DX | AY |    | O4 | WC | NH | EJ | PI |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 22 | 33 | 26 | 11 |    | 31 | 43 | 32 | 14 | 33 |
| h  | o  | l  | a  |    | m  | u  | n  | d  | o  |

### Clave de cifrado

La clave de cifrado viene determinada por el orden en el que aparecen los distintos caracteres en la matriz. Cambiando dicho orden, se alteran los caracteres que forman parte de cada fila y columna:

|       | **1** | **2** | **3** | **4** | **5** | **6** |
|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
| **1** |   M   |   U   |   R   |   C   |   I   |   E   |
| **2** |   L   |   A   |   G   |   O   |   P   |   Q   |
| **3** |   S   |   T   |   V   |   W   |   X   |   Y   |
| **4** |   Z   |   0   |   1   |   2   |   3   |   4   |
| **5** |   5   |   6   |   7   |   8   |   9   |   B   |
| **6** |   D   |   F   |   H   |   J   |   K   |   N   |

Ahora la fila 3 se codifica con los caracteres S, T, V, W, X o Y. La columna 4 se compone de C, O, W, 2, 8 y J.

### Cambios realizados en la herramienta **dice** sobre el algoritmo original

1. Para que **dice** pueda trabajar con cualquier tipo de mensaje e incluso pueda codificar archivos binarios, antes de codificar el mensaje, éste se convierte a **base64**.
2. La representación en **base64** utiliza 64 caracteres distintos [a-z][A-Z][0-9]+/ para representar la información. La matriz de cifrado se amplia a 8x8 para utilizar dichos caracteres.
3. Para facilitar los procesos, los índices de filas y columnas se cambian para comenzar en 0.

|       | **0** | **1** | **2** | **3** | **4** | **5** | **6** | **7** |
|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
| **0** |   a   |   b   |   c   |   d   |   e   |   f   |   g   |   h   |
| **1** |   i   |   j   |   k   |   l   |   m   |   n   |   o   |   p   |
| **2** |   q   |   r   |   s   |   t   |   u   |   v   |   w   |   x   |
| **3** |   y   |   z   |   A   |   B   |   C   |   D   |   E   |   F   |
| **4** |   G   |   H   |   I   |   J   |   K   |   L   |   M   |   N   |
| **5** |   O   |   P   |   Q   |   R   |   S   |   T   |   U   |   V   |
| **6** |   W   |   X   |   Y   |   Z   |   0   |   1   |   2   |   3   |
| **7** |   4   |   5   |   6   |   7   |   8   |   9   |   +   |   /   |

4. Base64 utiliza un carácter más, el símbolo igual (=), como carácter de relleno. Dicho carácter no se codifica.
5. La clave de cifrado es una cadena de 64 caracteres con un determinado orden *abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/* por ejemplo.

## Requisitos

La herramienta **dice** está programada mediante *Shell Script*. Está pensada para ser utilizada en sistemas operativos *Linux*, mediante *bash*. En concreto se ha desarrollado y testado en una distribución *Ubuntu*.
Para llevar a cabo la codificación/decodificación a base64, la herramienta **base64** debe estar instalada en el sistema. Esta herramienta forma parte del paquete **coreutils**.

Si necesitas instalarla, puedes hacerlo ejecutando:

```bash
sudo apt-get install coreutils
```
## Instalación

## Primeros pasos

Lo primero será generar una nueva clave de encriptación para nuestros mensajes. Inicialmente, **dice** utiliza la clave *abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/* para cifrar/descifrar mensajes.

La herramienta guarda la clave de encriptación en el archivo **~/.dice/key**. Este archivo se generará para cada usuario que utilice la herramienta, y sólo será accesible para él.

Para generar la clave de encriptación se utiliza la opción **-r** (*rotate*) de la herramienta.

La forma correcta de hacerlo es:

```bash
dice -r > my_key.txt
```

Esto generará una nueva clave de encriptación, que se almacenará en **~/.dice/key** y además se abrá exportado en *my_key.txt*. Asegúrate de hacer llegar el archivo *my_key.txt* a la persona con la que te quieres comunicar, y luego elimínalo de tu sistema.

El receptor de los mensajes tendrá que ejecutar:

```bash
dice -r my_key.txt
```

de esta forma establecerá el contenido de *my_key.txt* como su clave de encriptación. Asegúrate de que también borra el archivo.

## Codificando

Para codificar, utiliza la opción **-e**. Se puede codificar un mensaje recibido a través de la entrada estándar, o un archivo pasado como parámetro:

```bash
# Entrada estándar
echo "Hola mundo" | dice -e

# Archivo
dice -e archivo.txt
```

El mensaje codificado se puede recoger de la salida estándar.

## Decodificando

Para decodificar, utiliza la opción **-d**. Se puede decodificar un mensaje encriptado recibido a través de la entrada estándar, o un archivo pasado como parámetro:

```bash
# Entrada estándar
echo "a8GL9IGo08IBd8L4XF9ok0rs54ZQhx=" | dice -d

# Archivo
dice -d archivo.txt
```
El mensaje decodificado se puede recoger de la salida estándar. 

## Licencia

MIT License

Copyright (c) 2023 danuser2018

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Agradecimientos

- A ChatGPT. He de reconocer que mis conocimientos de shell script son bastantes básicos. Pero con la ayuda de ChatGPT he podido desarrollar esta herramienta.


