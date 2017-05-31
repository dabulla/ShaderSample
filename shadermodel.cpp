#include "shadermodel.h"
#include "shaderparameterinfo.h"

#include <QVariant>
#include <QOpenGLShaderProgram>
#include <QOpenGLFunctions_4_0_Core>

#include <QOpenGLDebugLogger>
#include <QOffscreenSurface>

void onMessageLogged(QOpenGLDebugMessage message)
{
    qDebug() << message;
}

ShaderModel::ShaderModel()
    : m_shaderProgram(nullptr)
{
    m_roleNameMapping[ParameterName] = "name";
    m_roleNameMapping[ParameterType] = "type";
    m_roleNameMapping[ParameterDatatype] = "datatype";
    m_roleNameMapping[ParameterValue] = "value";
    m_roleNameMapping[ParameterUniformLocation] = "location";
    m_roleNameMapping[ParameterData] = "data";

}

Qt3DRender::QShaderProgram *ShaderModel::shaderProgram() const
{
    return m_shaderProgram;
}

void ShaderModel::syncModel()
{
    QOpenGLDebugLogger logger;


    QOpenGLContext glContext;
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
    this->clear();
    // QOpenGLShaderProgram is not part of Qt3D.
    // It allows to parse the shader.
    QOpenGLShaderProgram shaderProgram;
    shaderProgram.create();
    if ( !shaderProgram.addShaderFromSourceCode(QOpenGLShader::Vertex, m_shaderProgram->vertexShaderCode() ) ) {
        qCritical() << QObject::tr( "Could not compile vertex shader. Log:" ) << shaderProgram.log();
    }
    if ( !shaderProgram.addShaderFromSourceCode( QOpenGLShader::Fragment, m_shaderProgram->fragmentShaderCode() ) ) {
        qCritical() << QObject::tr( "Could not compile fragment shader. Log:" ) << shaderProgram.log();
    }
    if(m_shaderProgram->geometryShaderCode().size() != 0) {
        if ( !shaderProgram.addShaderFromSourceCode( QOpenGLShader::Geometry, m_shaderProgram->geometryShaderCode() ) ) {
            qCritical() << QObject::tr( "Could not compile geometry shader. Log:" ) << shaderProgram.log();
        }
    }
    if(m_shaderProgram->tessellationControlShaderCode().size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::TessellationControl, m_shaderProgram->tessellationControlShaderCode() ) ) {
            qCritical() << QObject::tr( "Could not compile vertex tessellation control. Log:" ) << shaderProgram.log();
        }
    }
    if(m_shaderProgram->tessellationEvaluationShaderCode().size() != 0) {
        if ( !shaderProgram.addShaderFromSourceFile( QOpenGLShader::TessellationEvaluation, m_shaderProgram->tessellationEvaluationShaderCode() ) ) {
            qCritical() << QObject::tr( "Could not compile vertex tessellation evaluation. Log:" ) << shaderProgram.log();
        }
    }
    if(m_shaderProgram->computeShaderCode().size() != 0) {
        if ( !shaderProgram.addShaderFromSourceCode( QOpenGLShader::Compute, m_shaderProgram->computeShaderCode() ) ) {
            qCritical() << QObject::tr( "Could not compile compute shader. Log:" ) << shaderProgram.log();
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
        if(m_parameters.contains(name))
        {
            theUniform = m_parameters.value(name);
        }
        else
        {
            theUniform = m_parameters.value(name, new ShaderParameterInfo(this));
        }
        theUniform->setName( name );
        theUniform->setType( ShaderParameterInfo::Uniform );
        theUniform->setDatatype( static_cast<ShaderParameterInfo::ShaderParameterDatatype>(type) );
        theUniform->setUniformLocation( location );
        QStandardItem *csi = new QStandardItem();
        csi->setData(theUniform->name(), ParameterName);
        csi->setData(QVariant::fromValue(theUniform->type()), ParameterType);
        csi->setData(QVariant::fromValue(theUniform->datatype()), ParameterDatatype);
        csi->setData(QVariant::fromValue(theUniform), ParameterData);
        //csi->setData(childFullPath, ParameterValue);
        csi->setData(theUniform->uniformLocation(), ParameterUniformLocation);
        csi->setData(theUniform->isSubroutine(), ParameterIsSubroutine);
        csi->setData(theUniform->subroutineValues(), ParameterSubroutineValues);
        this->appendRow( csi );
    }
    shaderProgram.release();
    dummySurface.destroy();
}

QStringList ShaderModel::blacklist() const
{
    return m_blacklist;
}

void ShaderModel::setShaderProgram(Qt3DRender::QShaderProgram *shaderProgram)
{
    if (m_shaderProgram == shaderProgram)
        return;

    m_shaderProgram = shaderProgram;
    syncModel();
    Q_EMIT shaderProgramChanged(m_shaderProgram);
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
