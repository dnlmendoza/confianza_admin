import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import sys

def main():
    try:
        cred = credentials.Certificate('admin_key.json')
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        
        print("Conectado a Firestore. Iniciando auditoría de inventario...")
        
        docs = db.collection('Inventario').limit(100).stream()
        errores = []
        count = 0
        
        for doc in docs:
            count += 1
            data = doc.to_dict()
            doc_id = doc.id
            nombre = data.get('nombre', 'Sin nombre')
            
            # Validaciones generales
            if 'cantidad_minima' in data and not isinstance(data['cantidad_minima'], (int, float)):
                errores.append(f"- Producto '{nombre}' (ID: {doc_id}): 'cantidad_minima' es {type(data['cantidad_minima']).__name__}, se esperaba Número.")
                
            if 'menor_mayor' in data and not isinstance(data['menor_mayor'], bool):
                errores.append(f"- Producto '{nombre}' (ID: {doc_id}): 'menor_mayor' es {type(data['menor_mayor']).__name__}, se esperaba Booleano.")
            
            if 'costo' in data and not isinstance(data['costo'], (int, float)):
                 errores.append(f"- Producto '{nombre}' (ID: {doc_id}): 'costo' es {type(data['costo']).__name__}, se esperaba Número.")
                
            # Validar Subcoleccion lote
            lotes = db.collection('Inventario').document(doc_id).collection('lote').stream()
            for lote in lotes:
                lote_data = lote.to_dict()
                if 'cantidad' in lote_data and not isinstance(lote_data['cantidad'], (int, float)):
                    errores.append(f"- Producto '{nombre}' Lote {lote.id}: 'cantidad' es {type(lote_data['cantidad']).__name__}, se esperaba Número.")
                    
        print(f"Se analizaron {count} productos principales y sus lotes correspondientes.")
        
        if not errores:
            print("\n✅ AUDITORÍA EXITOSA: Todos los productos analizados cumplen perfectamente con los tipos de datos (Números y Booleanos) mostrados en tu ejemplo de consola.")
        else:
            print(f"\n🚨 SE ENCONTRARON {len(errores)} ERRORES DE FORMATO:")
            for err in errores[:30]:
                print(err)
            if len(errores) > 30:
                print(f"... y {len(errores) - 30} errores adicionales ocultos.")
                
    except Exception as e:
        print(f"Error crítico al auditar: {e}")

if __name__ == "__main__":
    main()
