import express from 'express';
import mongoose from 'mongoose';
import path from 'path';
import { fileURLToPath } from 'url';

// Obtener __dirname en módulos ES
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Definir el esquema de Mongoose para la colección de encuestas
const Encuesta = mongoose.model('Encuesta', new mongoose.Schema({
  nombre: String,
  email: String,
  edad: String,
  serieFavorita: String,
  vos: String,
  dispositivo: [String],
  razonAmor: String,
}));


const app = express();


app.get('/encuestados', async (_req, res) => {
  console.log('listando... encuesta..');
  try {
    const encuestas = await Encuesta.find();
    res.json(encuestas);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener datos de la encuesta.' });
  }
});

// Middleware para parsear URL-encoded y servir archivos estáticos
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));


mongoose.connect('mongodb://acervantes:password@my-mongo:27017/miapp?authSource=admin', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('Conectado a MongoDB');
})
.catch((error) => {
  console.error('Error al conectarse a MongoDB:', error.message);
  process.exit(1); 
});


app.get('/encuesta', (_req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'encuesta.html'));
});

app.post('/encuesta', async (req, res) => {
  const { nombre, email, edad, serieFavorita, vos, dispositivo, razonAmor } = req.body;
  console.log('Recibiendo respuesta de encuesta...');

  // Crear nueva entrada en la colección "Encuesta"
  await Encuesta.create({
    nombre,
    email,
    edad,
    serieFavorita,
    vos,
    dispositivo: dispositivo || [],
    razonAmor,
  });

  res.send(`
    <h1>¡Gracias por participar!</h1>
    <p>Tu voto por ${serieFavorita} ha sido registrado correctamente.</p>
    <a href="/encuesta">Volver a la encuesta</a>
    <a href="/encuestados">Listar encuestas</a>
  `);
});


// Iniciar el servidor si no estamos en modo de prueba
if (process.env.NODE_ENV !== 'test') {
  const server = app.listen(3000, () => {
    console.log('Listening on port 3000...');
  });
}

export default app;


