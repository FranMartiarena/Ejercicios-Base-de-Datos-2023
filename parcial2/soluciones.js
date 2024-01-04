//Nombre y Apellido: Francisco Martiarena
//Dni: 43524389
//ACLARACION: los ejercicios los escribí y ejecute en la shell de mongo "mongosh" para ubuntu. Despues los pegue en este archivo.


//Buscar las ventas realizadas en "London", "Austin" o "San Diego"; a un customer con edad mayor-igual a 18 años que tengan productos que hayan salido al menos 1000 y estén etiquetados (tags) como de tipo "school" o "kids" (pueden tener más etiquetas).
//Mostrar el id de la venta con el nombre "sale", la fecha (“saleDate"), el storeLocation, y el "email del cliente. No mostrar resultados anidados. 

db.sales.aggregate([{$match:{
                            "storeLocation":{$in:['London','Austin','San Diego']}, 
                            "customer.age":{$gte:18}, 
                            "items":
                                    {
                                    $elemMatch: 
                                                {
                                                "price":{$gte:1000},
                                                 $or:[{"tags":{$elemMatch:{$eq:'kids'}}}, {"tags":{$elemMatch:{$eq:'school'}}}]                                                
                                                }
                                    }
                            }
                    },
                     
                    {
                     $project:{"_id":0, sale:"$_id","saleDate":1, "storeLocation":1, email:"$customer.email"}
                    }
                    
                   ])


//Buscar las ventas de las tiendas localizadas en Seattle, donde el método de compra sea ‘In store’ o ‘Phone’ y se hayan realizado entre 1 de febrero de 2014 y 31 de enero de 2015 (ambas fechas inclusive). Listar el email y la satisfacción del cliente, y el monto total facturado, donde el monto de cada item se calcula como 'price * quantity'. Mostrar el resultado ordenados por satisfacción (descendente), frente a empate de satisfacción ordenar por email (alfabético). 



db.sales.aggregate([
                    {
                     $match:
                            {
                            "storeLocation":"Seattle",
                            "purchaseMethod":{$in:["In store", "Phone"]},
                            "saleDate":{$gte: ISODate('2014-02-01'), $lte: ISODate('2015-01-31')}
                            }
                    },
                    {
                     $project:
                             {
                             email:"$customer.email",
                             satisfaction:"$customer.satisfaction",
                             montoTotal: {$reduce: {input: "$items", initialValue:0, in:{$add:["$$value", {$multiply: ["$$this.price", "$$this.quantity"]}]}}} 
                             }
                    },
                    {
                    $sort: {"satisfaction":-1, "email":1}
                    }
                    
                  ])


//Crear la vista salesInvoiced que calcula el monto mínimo, monto máximo, monto total y monto promedio facturado por año y mes.  Mostrar el resultado en orden cronológico. No se debe mostrar campos anidados en el resultado.
//Aca tomo el monto como el precio total de los items de cada objeto sale.
//Asumo que es de todas los paises juntos

db.createView(
            "salesInvoiced",
            "sales",
            [
                    {
                    $addFields:
                               {
                               monto: {$reduce: {input: "$items", initialValue:0, in:{$add:["$$value", {$multiply: ["$$this.price", "$$this.quantity"]}]}}} 
                               }
                    },
                    
                    {
                    $group:
                          {
                          _id:{ year: { $year: "$saleDate"}, month: { $month: "$saleDate"}},
                          montoMinimo: {$min:"$monto"},
                          montoMaximo: {$max:"$monto"},
                          montoTotal: {$sum:"$monto"},
                          montoPromedio: {$avg:"$monto"},
                          }
                    },
                    
                    {
                    $sort:{"_id":1}
                    }
                    
             ])

//Mostrar el storeLocation, la venta promedio de ese local, el objetivo a cumplir de ventas (dentro de la colección storeObjectives) y la diferencia entre el promedio y el objetivo de todos los locales.
//Nuevamente asumo que una venta de un local es la suma de los precios de items en un objeto sale.
db.sales.aggregate([
                      {
                        $addFields:
                                   {
                                   monto: {$reduce: {input: "$items", initialValue:0, in:{$add:["$$value", {$multiply: ["$$this.price", "$$this.quantity"]}]}}} 
                                   }
                      },
                      
                      {
                        $group:
                               {
                               _id:"$storeLocation",
                               promedioVenta: {$avg:"$monto"},
                               }
                      },
                      
                      {
                        $lookup:{
                                from:"storeObjectives",
                                localField:"_id",
                                foreignField:"_id",
                                as:"objetivo"
                                }
                      },
                      
                      {
                      
                        $project:{
                                 "storeLocation":1,
                                 "promedioVenta":1,
                                 objetivoVenta:{ $arrayElemAt: [ "$objetivo.objective", 0 ] },
                                 diferencia: {$subtract: ["$promedioVenta", { $arrayElemAt: [ "$objetivo.objective", 0 ] }]}
                                 }
                      
                      }
                  ])

//Especificar reglas de validación en la colección sales utilizando JSON Schema. 
//Las reglas se deben aplicar sobre los campos: saleDate, storeLocation, purchaseMethod, y  customer ( y todos sus campos anidados ). Inferir los tipos y otras restricciones que considere adecuados para especificar las reglas a partir de los documentos de la colección. 
//Para testear las reglas de validación crear un caso de falla en la regla de validación y un caso de éxito (Indicar si es caso de falla o éxito)

db.runCommand( { 
                collMod: "sales",
                validator: { $jsonSchema: 
                                {
                                    bsonType: "object",
                                    required: [ "saleDate", "storeLocation", "purchaseMethod", "customer"],
                                    properties: 
                                    {
                                        saleDate:
                                        {
                                            bsonType: "date",
                                            description: "La fecha de venta debe ser tipo date"
                                        },
                                        
                                        storeLocation: 
                                        {
                                            enum:["Austin", "New York", "Denver", "Seattle", "London", "San Diego"],
                                            description: "La ubicacion del local debe ser valida."
                                        },
                                        purchaseMethod:
                                        {
                                            enum:["Online", "In store", "Phone"],
                                            description: "El metodo de pago debe ser valido."
                                        },
                                        customer:
                                        {
                                            bsonType: "object",
                                            required: ["gender", "age", "email", "satisfaction"],
                                            properties: 
                                            {
                                                gender:
                                                {
                                                    bsonType: "string",
                                                    description: "El genero debe ser un string"
                                                },
                                                age:
                                                {
                                                    bsonType: "int",
                                                    minimum:0,
                                                    maximum: 150,
                                                    description: "La edad debe ser un entero"
                                                },
                                                email:
                                                {
                                                    bsonType: "string",
                                                    description: "El email debe ser un string"
                                                },
                                                satisfaction:
                                                {
                                                    enum:[1,2,3,4,5],
                                                    description: "La satisfaccion debe ser un entero del 1 al 5 inclusives"
                                                },
                                            }
                                            
                                        }
                                    }
                               } 
                            },
                validationLevel: "moderate"

             } )

//Caso de falla
//No hay campo de cliente

db.sales.insertOne({
    saleDate: ISODate("2021-01-16T04:17:41.206Z"),
    storeLocation: "London",
    purchaseMethod: "Online"
});

//Caso de Exito

db.sales.insertOne({
    saleDate: ISODate("2021-01-16T04:17:41.206Z"),
    storeLocation: "London",
    purchaseMethod: "Online",
    customer:  {gender: 'M', age: 21, email: 'yo@quiero_un_diez.jaja', satisfaction: 5 }
});





