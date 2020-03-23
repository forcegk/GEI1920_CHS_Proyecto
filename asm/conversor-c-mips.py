#!/usr/bin/env python3
import sys, re

# Conversor pseudocódigo ensamblador C a ensamblador MIPS para el proyecto de
# Codeseño Hardware/Software 2019-2020
# x.veiga@udc.es - 20/03/2020
#
# Argumentos:
# conversor-c-mips.py <archivo fuente> <archivo destino> <definición funcion>
#
# Ejemplo: Convertir la función "MIPScore::codigoL1inv()" del
# archivo MIPScore.cpp y guardarla en L1inv.s
#
# conversor-c-mips.py MIPScore.cpp L1inv.s "void MIPScore::codigoL1inv()"

class Instruction:
    def __init__(self, name, replace_action):
        self.name = name
        self.replace_action = replace_action

# Reemplaza la string replacement entre las posiciones begin y end de content
def replace_str_position(content, begin, end, replacement):
    return content[0:begin] + replacement + content[end:-1]

# Obtiene todo el contenido entre "{}"
def get_structure_between_brackets(content):
    begin_index = 0 # Indice del primer "{"
    pending_brackets = 0 # Numero de "{" sin cerrar

    for i, c in enumerate(content): # Para cada caracter
        if c == '{': # Si es '{' aumenta numero de caracteres pendientes
            pending_brackets += 1
            if begin_index == 0:
                begin_index = i
        elif c == '}': # Si es '}' disminuye numero de caracteres pendientes
            pending_brackets -= 1

        # Si esta dentro de la estructura "{}" inicial y no quedan "{" abiertos,
        # devuelve las lineas de ese rango
        if begin_index > 0 and pending_brackets == 0:
            return content[begin_index+1:i]
    return None

# Obtiene la funcion especificada del codigo en C
def get_c_function(content, function_header):
    if function_header in content: # Si se encuentra la cabecera de la funcion
        # Busca todo el contenido entre {} desde la cabecera hasta el final
        return get_structure_between_brackets(content[content.index(function_header)+len(function_header):-1])
    return None

def delete_block_comments(content):
    res = []
    block = False # Indica si se esta dentro de un bloque ("/* ... */")

    for i in range(len(content[:-1])): # Para cada caracter menos el ultimo
        #sys.stdout.write(content[i])
        # Si se esta dentro de un bloque comentado
        if block:
            # Busca el caracter de fin ("*/") y sale del bloque sin anadir caracteres
            if content[i-1] == '*' and content[i] == '/':
                #sys.stdout.write('#end commented block#')
                block = False
        # Si se esta fuera de un bloque comentado
        else:
            # Busca secuencia de inicio
            if content[i] == '/' and content[i+1] == '*':
                #sys.stdout.write('#begin commented block#')
                block = True
            # Si no se encuentra, anade caracteres
            else:
                res.append(content[i])
    return ''.join(res)

# Matchea todas las instrucciones de la tabla y devuelve un objeto regex
def get_mips_instr(content, supported_instr):
    # Construye una expresion regex que matchea todas las supported_instr
    inst_regex = ''
    for inst in supported_instr[0:-2]:
        inst_regex += inst.name + '|' # inst "or" ... inst "or" ... inst
    inst_regex += supported_instr[-1].name # Ultima inst, para evitar añadir el "|"
    
    # Busca patrones con el formato "nombre_instr(...);", que no esten precedidas por //,
    # y las etiquetas "nombre_etiqueta:"
    
    regex = r'^(?: *|\t*)(?:(?:(?:' + inst_regex + r') *\(.+\);)|(?:[a-z|A-Z|0-9|-|_]*:))'
    return re.finditer(regex, content, re.MULTILINE)

# Realiza la accion correspondiente de la tabla en la instruccion especificada
def format_instr(instruction, supported_instr):
    line = instruction.strip()
    name = line.split('(')[0].strip()
    for i in supported_instr:
        if i.name == name:
            return i.replace_action(line)
    return line

# Formatea las instrucciones mips estandar
def format_mips_standard(instr):
    return instr.replace('(', ' ').replace(')', '').replace(';', '')

# Formatea las instrucciones LW y SW
def format_mips_word(instr):
    splits = instr.split(',')
    register = splits[1].strip()
    regex = re.compile(r'^R[A-za-z0-9]*(?: *|\t*)\+(?: *|\t*)(?:0b[0-9]*|0x[0-9]*|[0-9]*)(?: *|\t*)\)(?: *|\t*);$')

    # Para registro en formato Rxx + offset
    if regex.search(register) is not None:
        offset = register[1:].split('+')[1].strip().replace(')', '').replace(';', '')
        register = register[1:3].replace(';', '')
        res = splits[0].replace('(', ' ').lower() + ', ' + offset +'($' + register + ')'
    # Si solo contiene el nombre del registro Rxx
    elif register[0] == 'R':
        res = splits[0].replace('(', ' ').lower() + ', 0($' + register[1:].replace(';', '')
    else:
        # Para constantes directas, no es posible convertirlas directamente en la instruccion
        res = '# Error: lw/sw no soporta constantes directas. Necesita "addi" adicional'
        print(res, file=sys.stderr)
    return res

# Formatea las instrucciones con offset
def format_mips_offset(instr):
    splits = instr.split(',')
    res = splits[0].split('(', ' ') + ' ' + splits[2][0:-2].strip() + '(' + splits[1].strip() + ')'
    return res

# Formatea las instrucciones inmediatas (con una constante)
def format_mips_inmediate(instr):
    splits = instr.split(',')
    res = splits[0].replace('(', ' ') + ', ' + splits[1].strip() + ', ' + splits[2][0:-2].strip()
    return res

## Main ##
if len(sys.argv) != 4:
    print('Argumentos incorrectos. Uso: ' + sys.argv[0] + ' <archivo fuente> <archivo destino> <definicion funcion>')
    exit(1)

# Archivos fuente y destino
source_file = sys.argv[1]
dest_file = sys.argv[2]
function = sys.argv[3]

# Define cada instruccion y la accion a realizar para modificarla
supported_instr = [
    Instruction('LW'  , format_mips_word),
    Instruction('SW'  , format_mips_word),
    Instruction('add' , format_mips_standard),
    Instruction('sub' , format_mips_standard),
    Instruction('and' , format_mips_standard),
    Instruction('or'  , format_mips_standard),
    Instruction('xor' , format_mips_standard),
    Instruction('slt' , format_mips_standard),
    Instruction('mult', format_mips_standard),
    Instruction('mflo', format_mips_standard),
    Instruction('sll' , format_mips_standard),
    Instruction('srl' , format_mips_standard),
    Instruction('sra' , format_mips_standard),
    Instruction('sllv', format_mips_standard),
    Instruction('srlv', format_mips_standard),
    Instruction('srav', format_mips_standard),
    Instruction('addi', format_mips_inmediate),
    Instruction('andi', format_mips_inmediate),
    Instruction('ori' , format_mips_inmediate),
    Instruction('slti', format_mips_inmediate),
    Instruction('lui' , format_mips_inmediate),
    Instruction('beq' , format_mips_standard),
    Instruction('bne' , format_mips_standard),
    Instruction('blez', format_mips_standard),
    Instruction('bgtz', format_mips_standard),
    Instruction('j'   , format_mips_standard)]

# Lee archivo fuente
with open(source_file, 'r') as f:
    content = f.read()

# Busca la cabecera de la funcion deseada en el archivo,
# devuelve la string desde ese punto hasta el final
func_section  = content[content.find(function):]

# Recupera la seccion delimitada entre "{}"
func = get_structure_between_brackets(func_section)

# Elimina comentarios en bloque para que no interfieran
code = delete_block_comments(func)

# Busca elementos con sintaxis de instruccion MIPS
mips_instr = get_mips_instr(code, supported_instr)

# Convierte cada instruccion
res = ''
for i in mips_instr:
    res += format_instr(i.group(0), supported_instr) + '\n'

# Escribe archivo destino
with open(dest_file, 'w') as f:
    f.write(res)
    f.close()