#include "shadermodel.h"
#include "shaderparameterinfo.h"

#include <QVariant>
#include <QOpenGLShaderProgram>
#include <QOpenGLFunctions_4_0_Core>

#include <QOpenGLDebugLogger>
#include <QOffscreenSurface>
#include <QFile>

void onMessageLogged(QOpenGLDebugMessage message)
{
    qDebug() << message;
}

ShaderModel::ShaderModel()
    : m_isValid(false)
{
    m_roleNameMapping[ParameterName] = "name";
    m_roleNameMapping[ParameterType] = "type";
    m_roleNameMapping[ParameterDatatype] = "datatype";
    m_roleNameMapping[ParameterValue] = "value";
    m_roleNameMapping[ParameterUniformLocation] = "location";
    m_roleNameMapping[ParameterData] = "data";
}

ShaderModel::ShaderModel(const ShaderModel &other)
    : m_roleNameMapping(other.m_roleNameMapping)
    , m_blacklist(other.m_blacklist)
    , m_parameters(other.m_parameters)
    , m_vertexShader(other.m_vertexShader)
    , m_geometryShader(other.m_geometryShader)
    , m_tesselationControlShader(other.m_tesselationControlShader)
    , m_tesselationEvaluationShader(other.m_tesselationEvaluationShader)
    , m_fragmentShader(other.m_fragmentShader)
    , m_computeShader(other.m_computeShader)
    , m_isValid( false )
{
    m_roleNameMapping[ParameterName] = "name";
    m_roleNameMapping[ParameterType] = "type";
    m_roleNameMapping[ParameterDatatype] = "datatype";
    m_roleNameMapping[ParameterValue] = "value";
    m_roleNameMapping[ParameterUniformLocation] = "location";
    m_roleNameMapping[ParameterData] = "data";
}

void ShaderModel::syncModel()
{
    m_isValid = false;
    if(m_vertexShader.length() == 0 || m_fragmentShader.length() == 0) return;
    QOpenGLDebugLogger logger;

    QOpenGLContext glContext;
    QSurfaceFormat fmt = glContext.format();
    fmt.setOption(QSurfaceFormat::DebugContext);
    glContext.setFormat(fmt);
    glContext.create();
    QOffscreenSurface dummySurface;
    dummySurface.create();
    glContext.makeCurrent(&dummySurface);
    QOpenGLFunctions_4_0_Core *glFuncs = glContext.versionFunctions<QOpenGLFunctions_4_0_Core>();
    if ( !glFuncs ) {
        qWarning() << "Unsupported Profile: QOpenGLFunctions_4_0_Core";
        return;
    }
    if(!glFuncs->initializeOpenGLFunctions()) {
        qWarning() << "Could not initialize gl functions";
        return;
    }
    if ( logger.initialize() ) {
        connect( &logger, &QOpenGLDebugLogger::messageLogged, &onMessageLogged);//, Qt::DirectConnection );
        logger.startLogging( QOpenGLDebugLogger::SynchronousLogging );
        logger.enableMessages();
//        QVector<uint> disabledMessages;
//        disabledMessages.push_back(131169); // Framebuffer detailed info
//        disabledMessages.push_back(131185); // Buffer Detailed Info
//        disabledMessages.push_back(131204); // Texture has mipmaps, filter is inconsistent with mipmaps (framebuffer?)
//        //disabledMessages.push_back(131218);
//        disabledMessages.push_back(131184);
//        logger.disableMessages(disabledMessages);
    }
    //this->clear();
    // QOpenGLShaderProgram is not part of Qt3D.
    // It allows to parse the shader.
    QOpenGLShaderProgram shaderProgram;
    shaderProgram.create();
    if ( !shaderProgram.addShaderFromSourceFile(QOpenGLShader::Vertex, m_vertexShader ) ) {
        qCritical() << QObject::tr( "Could not compile vertex shader. Log:" ) << shaderProgram.log();
        return;
    }
    if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::Fragment, m_fragmentShader ) ) {
        qCritical() << QObject::tr( "Could not compile fragment shader. Log:" ) << shaderProgram.log();
        return;
    }
    if(m_geometryShader.size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::Geometry, m_geometryShader ) ) {
            qCritical() << QObject::tr( "Could not compile geometry shader. Log:" ) << shaderProgram.log();
            return;
        }
    }
    if(m_tesselationControlShader.size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::TessellationControl, m_tesselationControlShader ) ) {
            qCritical() << QObject::tr( "Could not compile vertex tessellation control. Log:" ) << shaderProgram.log();
            return;
        }
    }
    if(m_tesselationEvaluationShader.size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::TessellationEvaluation, m_tesselationEvaluationShader ) ) {
            qCritical() << QObject::tr( "Could not compile vertex tessellation evaluation. Log:" ) << shaderProgram.log();
            return;
        }
    }
    if(m_computeShader.size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::Compute, m_computeShader ) ) {
            qCritical() << QObject::tr( "Could not compile compute shader. Log:" ) << shaderProgram.log();
            return;
        }
    }

    shaderProgram.bind();
    GLint total = -1;
    glFuncs->glGetProgramiv( shaderProgram.programId(), GL_ACTIVE_UNIFORMS, &total );
    for(int i=0; i<total; ++i)
    {
        int name_len=-1, num=-1;
        GLenum type = GL_ZERO;
        char nameBuff[200];
        glFuncs->glGetActiveUniform( shaderProgram.programId(), GLuint(i), sizeof(nameBuff)-1,
            &name_len, &num, &type, nameBuff );
        nameBuff[name_len] = 0;
        GLuint location = glFuncs->glGetUniformLocation( shaderProgram.programId(), nameBuff );
        Q_ASSERT(location == i);
        QString name(nameBuff);
        if(m_blacklist.contains(name))
        {
            continue;
        }

        ShaderParameterInfo *theUniform;
        QStandardItem *csi;
        if(m_parameters.contains(name))
        {
            theUniform = m_parameters.value(name);
            bool found = false;
            for(int i=0 ; i<rowCount() ; ++i)
            {
                csi = item(i, 0);
                if(csi->data(ParameterName).toString() == name)
                {
                    found = true;
                    break;
                }
            }
            Q_ASSERT(found);
        }
        else
        {
            theUniform = new ShaderParameterInfo(this);
            m_parameters.insert(name, theUniform );
            csi = new QStandardItem();
            this->appendRow( csi );
        }
        theUniform->setName( name );
        theUniform->setType( ShaderParameterInfo::Uniform );
        theUniform->setDatatype( static_cast<ShaderParameterInfo::ShaderParameterDatatype>(type) );
        theUniform->setUniformLocation( location );
        theUniform->setIsSubroutine( false );
        csi->setData(theUniform->name(), ParameterName);
        csi->setData(QVariant::fromValue(theUniform->type()), ParameterType);
        csi->setData(QVariant::fromValue(theUniform->datatype()), ParameterDatatype);
        csi->setData(QVariant::fromValue(theUniform), ParameterData);
        //csi->setData(childFullPath, ParameterValue);
        csi->setData(theUniform->uniformLocation(), ParameterUniformLocation);
        csi->setData(theUniform->isSubroutine(), ParameterIsSubroutine);
        csi->setData(theUniform->subroutineValues(), ParameterSubroutineValues);
    }
    /// Subroutines are special...
    /// Subroutines can be different for each shader stage
    total = -1;
    int shaderStages[] = {GL_VERTEX_SHADER,
                          GL_TESS_CONTROL_SHADER,
                          GL_TESS_EVALUATION_SHADER,
                          GL_GEOMETRY_SHADER,
                          GL_FRAGMENT_SHADER,
                          GL_COMPUTE_SHADER};
    for(unsigned int shaderStageIndex=0 ; shaderStageIndex<sizeof(shaderStages)/sizeof(shaderStages[0]) ; ++shaderStageIndex)
    {
        int shaderStage = shaderStages[shaderStageIndex];

        QList<QString> subroutineNames;

        glFuncs->glGetProgramStageiv(shaderProgram.programId(), shaderStage, GL_ACTIVE_SUBROUTINES, &total);
        for(int i=0; i<total; ++i)
        {
            int name_len=-1;
            char nameBuff[200];
            glFuncs->glGetActiveSubroutineName(shaderProgram.programId(), shaderStage, GLuint(i), 200, &name_len, nameBuff);
            nameBuff[name_len] = 0;
            subroutineNames.append( nameBuff );
        }

        //m_qmlShaderProperties.m_subroutines[ shaderStage ].clear();
        glFuncs->glGetProgramStageiv(shaderProgram.programId(), shaderStage, GL_ACTIVE_SUBROUTINE_UNIFORMS, &total);
        for(int i=0; i<total; ++i)
        {
            int name_len=-1;
            char nameBuff[200];
            GLint num_subroutines;
            int subroutines[100];
            glFuncs->glGetActiveSubroutineUniformiv(shaderProgram.programId(), shaderStage, GLuint(i), GL_NUM_COMPATIBLE_SUBROUTINES, &num_subroutines);
            glFuncs->glGetActiveSubroutineUniformiv(shaderProgram.programId(), shaderStage, GLuint(i), GL_COMPATIBLE_SUBROUTINES, subroutines);
            glFuncs->glGetActiveSubroutineUniformName(shaderProgram.programId(), shaderStage, GLuint(i), 200, &name_len, nameBuff);
            nameBuff[name_len] = 0;
            QString name(nameBuff);
            if(m_blacklist.contains(name))
            {
                continue;
            }
            ShaderParameterInfo *theUniform;
            QStandardItem *csi;
            if(m_parameters.contains(name))
            {
                theUniform = m_parameters.value(name);
                bool found = false;
                for(int i=0 ; i<rowCount() ; ++i)
                {
                    csi = item(i, 0);
                    if(csi->data(ParameterName).toString() == name)
                    {
                        found = true;
                        break;
                    }
                }
                Q_ASSERT(found);
            }
            else
            {
                theUniform = new ShaderParameterInfo(this);
                m_parameters.insert(name, theUniform );
                csi = new QStandardItem();
                this->appendRow( csi );
            }

            theUniform->setName( name );
            theUniform->setType( ShaderParameterInfo::Uniform );
            theUniform->setDatatype( static_cast<ShaderParameterInfo::ShaderParameterDatatype>(ShaderParameterInfo::UNSIGNED_INT) );
            theUniform->setUniformLocation( i );
            theUniform->setIsSubroutine( true );
            //theUniform->set_subroutineShaderType( shaderStage );
            theUniform->m_subroutineValues.clear();
            for( int idx=0 ; idx < num_subroutines ; ++idx)
            {
                theUniform->m_subroutineValues.append(subroutineNames.at(subroutines[idx]));
            }

            csi->setData(theUniform->name(), ParameterName);
            csi->setData(QVariant::fromValue(theUniform->type()), ParameterType);
            csi->setData(QVariant::fromValue(theUniform->datatype()), ParameterDatatype);
            csi->setData(QVariant::fromValue(theUniform), ParameterData);
            //csi->setData(childFullPath, ParameterValue);
            csi->setData(theUniform->uniformLocation(), ParameterUniformLocation);
            csi->setData(theUniform->isSubroutine(), ParameterIsSubroutine);
            csi->setData(theUniform->subroutineValues(), ParameterSubroutineValues);
        }
    }
    shaderProgram.release();
    dummySurface.destroy();
    m_isValid = true;
}

QStringList ShaderModel::blacklist() const
{
    return m_blacklist;
}

QString ShaderModel::vertexShader() const
{
    return m_vertexShader;
}

QString ShaderModel::geometryShader() const
{
    return m_geometryShader;
}

QString ShaderModel::tesselationControlShader() const
{
    return m_tesselationControlShader;
}

QString ShaderModel::tesselationEvaluationShader() const
{
    return m_tesselationEvaluationShader;
}

QString ShaderModel::fragmentShader() const
{
    return m_fragmentShader;
}

QString ShaderModel::computeShader() const
{
    return m_computeShader;
}

bool ShaderModel::isValid() const
{
    return m_isValid;
}

void ShaderModel::setBlacklist(QStringList blacklist)
{
    if (m_blacklist == blacklist)
        return;

    m_blacklist = blacklist;
    Q_EMIT blacklistChanged(m_blacklist);
}

QHash<int, QByteArray> ShaderModel::roleNames() const
{
    return m_roleNameMapping;
}

void ShaderModel::setVertexShader(QString vertexShader)
{
    if (m_vertexShader == vertexShader)
        return;

    m_vertexShader = vertexShader;
    syncModel();
    Q_EMIT vertexShaderChanged(m_vertexShader);
}

void ShaderModel::setGeometryShader(QString geometryShader)
{
    if (m_geometryShader == geometryShader)
        return;

    m_geometryShader = geometryShader;
    syncModel();
    Q_EMIT geometryShaderChanged(m_geometryShader);
}

void ShaderModel::setTesselationControlShader(QString tesselationControlShader)
{
    if (m_tesselationControlShader == tesselationControlShader)
        return;

    m_tesselationControlShader = tesselationControlShader;
    syncModel();
    Q_EMIT tesselationControlShaderChanged(m_tesselationControlShader);
}

void ShaderModel::setTesselationEvaluationShader(QString tesselationEvaluationShader)
{
    if (m_tesselationEvaluationShader == tesselationEvaluationShader)
        return;

    m_tesselationEvaluationShader = tesselationEvaluationShader;
    syncModel();
    Q_EMIT tesselationEvaluationShaderChanged(m_tesselationEvaluationShader);
}

void ShaderModel::setFragmentShader(QString fragmentShader)
{
    if (m_fragmentShader == fragmentShader)
        return;

    m_fragmentShader = fragmentShader;
    syncModel();
    Q_EMIT fragmentShaderChanged(m_fragmentShader);
}

void ShaderModel::setComputeShader(QString computeShader)
{
    if (m_computeShader == computeShader)
        return;

    m_computeShader = computeShader;
    syncModel();
    Q_EMIT computeShaderChanged(m_computeShader);
}
